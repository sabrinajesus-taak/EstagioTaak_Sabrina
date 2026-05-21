// 1. PEGA O PEDIDO (Para pegar os locais: Cidade, Estado, CD)
Order ped = [SELECT Id, AccountId, City__c, State__c, Country__c, DistributionCenter__c 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1];

// 2. PEGA O ITEM (Para pegar o Produto real que está lá)
OrderItem item = [SELECT Id, Product2Id FROM OrderItem 
                 WHERE OrderId = :ped.Id AND Product2.Name LIKE '%Colheitadeira%' LIMIT 1];

// 3. LIMPEZA TOTAL (Para o teste ser puro)
delete [SELECT Id FROM Margem__c WHERE Product__c = :item.Product2Id];
delete [SELECT Id FROM Freight__c WHERE Product__c = :item.Product2Id];

// 4. CRIA A MARGEM (Match: Produto + Conta + Cidade + Estado + CD)
Margem__c m1 = new Margem__c();
m1.Product__c = item.Product2Id;
m1.Account__c = ped.AccountId;
m1.City__c = ped.City__c;                   
m1.State__c = ped.State__c;                 
m1.DistributionCenter__c = ped.DistributionCenter__c; 
m1.MarginValuePercent__c = 45;
m1.Status__c = 'Approved';
insert m1;

// 5. CRIA O FRETE (Match: Produto + Estado + CD) - RESPEITANDO A REGRA DE VALIDAÇÃO
Freight__c f = new Freight__c();
f.Product__c = item.Product2Id;
f.State__c = ped.State__c;                 // ID do Lookup de Estado (Obrigatório)
f.City__c = ped.City__c;                   
f.DistributionCenter__c = ped.DistributionCenter__c; // ORIGEM OBRIGATÓRIA!
f.FreightValue__c = 50.00;
f.Status__c = 'Approved';
insert f;

// 6. UPDATE PARA DISPARAR O PRICINGSERVICE (O Momento da Verdade)
update item;

// 7. VERIFICAÇÃO FINAL (AUDITORIA)
OrderItem res = [SELECT MarginPercentage__c, FreightValue__c, UnitPrice FROM OrderItem WHERE Id = :item.Id];

System.debug('--- 🏁 AUDITORIA FINAL ---');
System.debug('Margem Aplicada: ' + res.MarginPercentage__c + '%');
System.debug('Frete Aplicado: R$ ' + res.FreightValue__c);
System.debug('Preço Unitário Final: R$ ' + res.UnitPrice);

if(res.MarginPercentage__c == 45) {
    System.debug('✅ VITÓRIA, SABRINA! O 45% finalmente apareceu no Item!');
}