// 1. Pega o CD e a Cidade que estão DE FATO no seu pedido
Order ped = [SELECT Id, DistributionCenter__c, City__c FROM Order WHERE OrderNumber = '00000100' LIMIT 1];

// 2. Pega o item da Colheitadeira que a gente acabou de inserir
OrderItem item = [SELECT Id, Product2Id FROM OrderItem WHERE OrderId = :ped.Id LIMIT 1];

// 3. ATUALIZA A MARGEM para o CD/Cidade do pedido (O "casamento" dos dados)
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];
insert new Margem__c(
    Product__c = item.Product2Id,
    DistributionCenter__c = ped.DistributionCenter__c, // Usa o CD do pedido!
    City__c = ped.City__c,                             // Usa a Cidade do pedido!
    MarginValuePercent__c = 45,
    Status__c = 'Approved'
);

// 4. DÁ UM "TOTÓ" NO ITEM PARA A TRIGGER RECALCULAR
update item;

// 5. O PRINT DA VITÓRIA
OrderItem res = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];
System.debug('--- 🏁 AGORA SIM, SABRINA! 45% NA TELA! ---');
System.debug('Margem Final: ' + res.MarginPercentage__c + '%');
System.debug('Preço com Margem: R$ ' + res.UnitPrice);