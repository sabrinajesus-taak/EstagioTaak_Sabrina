// 1. DADOS DO PEDIDO (Pegando o CD e a Cidade direto do Pedido 00000100)
Order ped = [SELECT Id, DistributionCenter__c, City__c, AccountId 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1];

// Busca a Colheitadeira que está no pedido
OrderItem item = [SELECT Id, Product2Id FROM OrderItem 
                 WHERE OrderId = :ped.Id AND Product2.Name LIKE '%Colheitadeira%' LIMIT 1];

// 2. LIMPEZA (Para o teste ser limpo e novo)
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];
delete [SELECT Id FROM Freight__c WHERE Product__c = :item.Product2Id];

// 3. CRIA A MARGEM (45%) - Incluindo o Centro de Distribuição!
insert new Margem__c(
    Product__c = item.Product2Id,
    Account__c = ped.AccountId,
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c, // OBRIGATÓRIO!
    MarginValuePercent__c = 45,
    Status__c = 'Approved'
);

// 4. CRIA O FRETE (R$ 50,00) - Incluindo o Centro de Distribuição!
insert new Freight__c(
    Product__c = item.Product2Id,
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c, // OBRIGATÓRIO!
    FreightValue__c = 50.00,
    Status__c = 'Approved'
);

// 5. UPDATE PARA DISPARAR A TRIGGER E O PRICINGSERVICE
update item;

// 6. VERIFICAÇÃO FINAL (AUDITORIA)
OrderItem res = [SELECT MarginPercentage__c, FreightValue__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];

System.debug('--- 🏆 AUDITORIA FINALIZADA ---');
System.debug('Centro de Distribuição Utilizado: ' + ped.DistributionCenter__c);
System.debug('Margem Gravada no Item: ' + res.MarginPercentage__c + '%');
System.debug('Frete Gravada no Item: R$ ' + res.FreightValue__c);
System.debug('Preço Final Calculado: R$ ' + res.UnitPrice);

if(res.MarginPercentage__c == 45) {
    System.debug('✅ TAREFA CONCLUÍDA! O CD bateu e o cálculo funcionou!');
} else {
    System.debug('❌ Ainda null? Verifica se o Status na sua Picklist é "Approved" ou "Aprovado"!');
}