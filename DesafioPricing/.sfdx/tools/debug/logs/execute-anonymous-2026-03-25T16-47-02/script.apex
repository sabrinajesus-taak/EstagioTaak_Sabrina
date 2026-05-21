// 1. DADOS DO PEDIDO (Pegando Cidade, CD e o ESTADO que a Regra de Validação exige)
Order ped = [SELECT Id, DistributionCenter__c, City__c, ShippingState, AccountId 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1];

// Busca a Colheitadeira
OrderItem item = [SELECT Id, Product2Id FROM OrderItem 
                 WHERE OrderId = :ped.Id AND Product2.Name LIKE '%Colheitadeira%' LIMIT 1];

// 2. LIMPEZA
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];
delete [SELECT Id FROM Freight__c WHERE Product__c = :item.Product2Id];

// 3. CRIA A MARGEM (Match: Produto + Conta + Cidade + CD)
insert new Margem__c(
    Product__c = item.Product2Id,
    Account__c = ped.AccountId,
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    MarginValuePercent__c = 45,
    Status__c = 'Approved'
);

// 4. CRIA O FRETE (Match: Produto + Estado + CD) - AGORA COM O ESTADO DO PEDIDO!
insert new Freight__c(
    Product__c = item.Product2Id,
    State__c = ped.ShippingState,      // <--- O que faltava para a Regra de Validação!
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    FreightValue__c = 50.00,
    Status__c = 'Approved'
);

// 5. UPDATE PARA CALCULAR
update item;

// 6. VERIFICAÇÃO FINAL
OrderItem res = [SELECT MarginPercentage__c, FreightValue__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];

System.debug('--- 🏆 AGORA O SALESFORCE DEIXOU! ---');
System.debug('Estado do Pedido: ' + ped.ShippingState);
System.debug('Margem Gravada: ' + res.MarginPercentage__c + '%');
System.debug('Frete Gravado: R$ ' + res.FreightValue__c);
System.debug('Preço Final: R$ ' + res.UnitPrice);

if(res.MarginPercentage__c == 45) {
    System.debug('✅ SUCESSO ABSOLUTO! O 45% finalmente apareceu!');
}