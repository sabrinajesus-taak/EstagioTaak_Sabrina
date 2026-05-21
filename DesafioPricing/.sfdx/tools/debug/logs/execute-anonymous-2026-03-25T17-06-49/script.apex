// 1. DADOS REAIS
Order ped = [SELECT Id, AccountId, City__c, State__c, Country__c, DistributionCenter__c 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1];
OrderItem item = [SELECT Id, Product2Id FROM OrderItem 
                 WHERE OrderId = :ped.Id AND Product2.Name LIKE '%Colheitadeira%' LIMIT 1];

// 2. LIMPEZA
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];
delete [SELECT Id FROM Freight__c WHERE Product__c = :item.Product2Id];

// 3. CRIAÇÃO DA MARGEM (45%) - Usando o padrão de Underline da sua classe
insert new Margem__c(
    Product__c = item.Product2Id,
    Account__c = ped.AccountId,
    City__c = ped.City__c,
    State__c = ped.State__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    MarginValuePercent__c = 45,
    Status__c = 'Approved'
);

// 4. CRIAÇÃO DO FRETE (R$ 50,00) - Usando o padrão SEM Underline da sua classe
insert new Freight__c(
    Product__c = item.Product2Id,
    State__c = ped.State__c,
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    FreightValue__c = 50.00,
    Status__c = 'Approved'
);

// 5. O PULO DO GATO: Vamos debugar o que a Trigger está vendo!
update item;

// 6. VERIFICAÇÃO FINAL
OrderItem res = [SELECT MarginPercentage__c, FreightValue__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];

System.debug('--- 🏁 RESULTADO FINAL ---');
System.debug('ID Produto: ' + item.Product2Id);
System.debug('ID Cidade: ' + ped.City__c);
System.debug('ID CD: ' + ped.DistributionCenter__c);
System.debug('Margem no Item: ' + res.MarginPercentage__c + '%');
System.debug('Frete no Item: R$ ' + res.FreightValue__c);
System.debug('Preço: R$ ' + res.UnitPrice);