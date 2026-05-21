// 1. PEGA OS DADOS DO PEDIDO
Order ped = [SELECT Id, AccountId, City__c, State__c, Country__c, DistributionCenter__c 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1];

// Busca o item da Colheitadeira
OrderItem item = [SELECT Id, Product2Id FROM OrderItem 
                 WHERE OrderId = :ped.Id AND Product2.Name LIKE '%Colheitadeira%' LIMIT 1];

// 2. LIMPEZA TOTAL (Para garantir que a Trigger busque os novos)
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];
delete [SELECT Id FROM Freight__c WHERE Product__c = :item.Product2Id];

// 3. CRIA A MARGEM (Match: Produto + Conta + Cidade + CD)
// O Status 'Approved' deve bater com o SELECT da sua Trigger
insert new Margem__c(
    Product__c = item.Product2Id,
    Account__c = ped.AccountId,
    City__c = ped.City__c,
    State__c = ped.State__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    MarginValuePercent__c = 45,
    Status__c = 'Approved' 
);

// 4. CRIA O FRETE (R$ 50,00)
insert new Freight__c(
    Product__c = item.Product2Id,
    State__c = ped.State__c,
    City__c = ped.City__c,
    DistributionCenter__c = ped.DistributionCenter__c,
    FreightValue__c = 50.00,
    Status__c = 'Approved'
);

// 5. O PULO DO GATO: ZERAR OS CAMPOS NO ITEM ANTES DO UPDATE
// Isso força a Trigger a preencher do zero e a gente vê a mudança!
item.MarginPercentage__c = null;
item.FreightValue__c = null;
update item;

// 6. VERIFICAÇÃO FINAL (O MOMENTO DO PRINT!)
OrderItem res = [SELECT MarginPercentage__c, FreightValue__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];

System.debug('--- 🏆 AGORA SIM, SABRINA! ---');
System.debug('Margem Encontrada: ' + res.MarginPercentage__c + '%');
System.debug('Frete Encontrado: R$ ' + res.FreightValue__c);
System.debug('Preço Final com Margem: R$ ' + res.UnitPrice);

if(res.MarginPercentage__c != null && res.MarginPercentage__c > 0) {
    System.debug('✅ TUDO CERTINHO! PODE TIRAR O PRINT!');
} else {
    System.debug('❓ Se ainda der null, verifique se a sua Trigger OrdemItemHandler está ATIVA nas Configurações.');
}