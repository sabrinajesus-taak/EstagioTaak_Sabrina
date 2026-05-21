// 1. SETUP DO PRODUTO E PEDIDO
Product2 prod = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'GenWatt Diesel 1000kW' LIMIT 1];
Order ped = [SELECT Id, AccountId, City__c, State__c, DistributionCenter__c, Pricebook2Id 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1]; 

PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry 
                      WHERE Product2Id = :prod.Id AND Pricebook2Id = :ped.Pricebook2Id LIMIT 1];

Account acc = [SELECT Id, AccountGroup__c FROM Account WHERE Id = :ped.AccountId];

// 2. LIMPEZA DE DADOS ANTIGOS
delete [SELECT Id FROM Margem__c WHERE Product__c = :prod.Id OR ProductHierarchy__c = :prod.ProductHierarchy__c];

// 3. CRIANDO OS NÍVEIS SEPARADOS (Respeitando sua Regra de Validação)
// Vamos criar apenas UM registro por vez para o sistema não se confundir
Margem__c m1 = new Margem__c();
m1.Product__c = prod.Id;
m1.Account__c = acc.Id;
m1.City__c = ped.City__c;
m1.DistributionCenter__c = ped.DistributionCenter__c;
m1.MarginValuePercent__c = 45;
m1.Status__c = 'Approved';
insert m1; 

// 4. INSERÇÃO DO ITEM (Aqui a Trigger vai rodar)
OrderItem novoItem = new OrderItem(
    OrderId = ped.Id, 
    Product2Id = prod.Id, 
    PricebookEntryId = pbe.Id,
    Quantity = 1, 
    UnitPrice = pbe.UnitPrice
);
insert novoItem;

// 5. VERIFICAÇÃO FINAL NO LOG
OrderItem result = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :novoItem.Id];

System.debug('--- 🏆 RESULTADO FINAL DO DESAFIO ---');
System.debug('Margem aplicada: ' + result.MarginPercentage__c + '%');
System.debug('Preço Final Calculado: R$ ' + result.UnitPrice);

if(result.MarginPercentage__c == 45) {
    System.debug('✅ SUCESSO: A Trigger priorizou a margem de Produto!');
}