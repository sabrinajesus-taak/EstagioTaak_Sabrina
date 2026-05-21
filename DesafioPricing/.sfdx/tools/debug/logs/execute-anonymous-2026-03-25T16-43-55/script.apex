// 1. PEGA O PEDIDO E A COLHEITADEIRA (DNA do Pedido)
Order ped = [SELECT Id, DistributionCenter__c, City__c, State__c, AccountId, ShippingState 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1];

// Busca o item que a gente já inseriu (garantindo que estamos no registro certo)
OrderItem item = [SELECT Id, Product2Id, PricebookEntryId FROM OrderItem 
                 WHERE OrderId = :ped.Id AND Product2.Name LIKE '%Colheitadeira%' LIMIT 1];

// 2. LIMPEZA (Para não ter lixo de teste anterior)
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];
delete [SELECT Id FROM Freight__c WHERE Product__c = :item.Product2Id];
// delete [SELECT Id FROM Imposto__c WHERE Product__c = :item.Product2Id]; // Descomente se tiver objeto de Imposto

// 3. CRIA A MARGEM (45%) - MATCH COM SEU SCRIPT (Produto + Conta + Cidade)
insert new Margem__c(
    Product__c = item.Product2Id,
    Account__c = ped.AccountId,
    City__c = ped.City__c,
    MarginValuePercent__c = 45,
    Status__c = 'Approved'
);

// 4. CRIA O FRETE (Exemplo: R$ 50,00) - MATCH COM SEU SCRIPT (Produto + Cidade + CD)
insert new Freight__c(
    Product__c = item.Product2Id,
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    FreightValue__c = 50.00,
    Status__c = 'Approved'
);

// 5. DISPARA O CÁLCULO (Update no item chama a Trigger -> chama o PricingService)
update item;

// 6. O GRANDE FINAL (Auditando os campos)
OrderItem res = [SELECT MarginPercentage__c, FreightValue__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];

System.debug('--- 🏁 RESULTADO DA AUDITORIA ---');
System.debug('Margem Aplicada: ' + res.MarginPercentage__c + '%');
System.debug('Frete Aplicado: R$ ' + res.FreightValue__c);
System.debug('Preço Final Calculado: R$ ' + res.UnitPrice);

if(res.MarginPercentage__c == 45) {
    System.debug('✅ VITÓRIA! A CLASSE PREENCHEU A MARGEM E FEZ A CONTA!');
} else {
    System.debug('❌ A Margem ainda está null. Verifique se os nomes dos campos no SELECT do PricingService batem com o Objeto.');
}