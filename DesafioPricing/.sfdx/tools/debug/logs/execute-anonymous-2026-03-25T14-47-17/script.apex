// 1. Limpando o terreno
Order ped = [SELECT Id, Pricebook2Id FROM Order WHERE OrderNumber = '00000100' LIMIT 1];
delete [SELECT Id FROM OrderItem WHERE OrderId = :ped.Id]; // Remove o GenWatt ou qualquer outro que esteja lá

// 2. Configura a tabela certa agora que o pedido está vazio
Id standardPBId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
ped.Pricebook2Id = standardPBId;
update ped;

// 3. Pega o preço da Colheitadeira
PricebookEntry pbe = [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry 
                      WHERE Product2.Name LIKE '%Colheitadeira%' 
                      AND Pricebook2Id = :standardPBId AND IsActive = true LIMIT 1];

// 4. Cria a MARGEM (Criterio 1: 18 níveis)
delete [SELECT Id FROM Margem__c WHERE Product__c = :pbe.Product2Id];
Margem__c m = new Margem__c(
    Product__c = pbe.Product2Id,
    MarginValuePercent__c = 45,
    Status__c = 'Approved',
    DistributionCenter__c = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id // Pega um CD qualquer
);
insert m;

// 5. Insere o item final
OrderItem finalItem = new OrderItem(
    OrderId = ped.Id,
    Product2Id = pbe.Product2Id,
    PricebookEntryId = pbe.Id,
    Quantity = 1,
    UnitPrice = pbe.UnitPrice
);
insert finalItem;

// 6. RESULTADO
OrderItem res = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :finalItem.Id];
System.debug('--- 🏆 ACABOU O PERRENGUE! ---');
System.debug('Margem: ' + res.MarginPercentage__c + '%');
System.debug('Preço: R$ ' + res.UnitPrice);