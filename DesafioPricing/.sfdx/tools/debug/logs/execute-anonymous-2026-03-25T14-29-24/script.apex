// 1. SETUP DO PRODUTO E PEDIDO (Usando o que você já tem na Org)
Product2 prod = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'GenWatt Diesel 1000kW' LIMIT 1];
Order ped = [SELECT Id, AccountId, City__c, State__c, DistributionCenter__c, Pricebook2Id 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1]; 

PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry 
                      WHERE Product2Id = :prod.Id AND Pricebook2Id = :ped.Pricebook2Id LIMIT 1];

Account acc = [SELECT Id, AccountGroup__c FROM Account WHERE Id = :ped.AccountId];

// 2. LIMPEZA (Para o teste ser 100% confiável)
delete [SELECT Id FROM Margem__c WHERE Product__c = :prod.Id OR ProductHierarchy__c = :prod.ProductHierarchy__c];

// 3. CRIANDO A MARGEM (Aprovada e Específica)
Margem__c m1 = new Margem__c();
m1.Product__c = prod.Id;
m1.Account__c = acc.Id;
m1.City__c = ped.City__c;
m1.DistributionCenter__c = ped.DistributionCenter__c;
m1.MarginValuePercent__c = 45; // Valor que queremos ver no resultado
m1.Status__c = 'Approved';
insert m1; 

// 4. INSERÇÃO DO ITEM (Onde a Trigger faz o cálculo)
OrderItem novoItem = new OrderItem(
    OrderId = ped.Id, 
    Product2Id = prod.Id, 
    PricebookEntryId = pbe.Id,
    Quantity = 1, 
    UnitPrice = pbe.UnitPrice
);
insert novoItem;

// 5. VERIFICAÇÃO FINAL (Usando o nome correto: MarginPercentage__c)
OrderItem result = [SELECT Id, MarginPercentage__c, UnitPrice, FreightValue__c 
                   FROM OrderItem 
                   WHERE Id = :novoItem.Id];

System.debug('--- 🏆 RESULTADO DO DESAFIO ---');
System.debug('Margem aplicada no Item: ' + result.MarginPercentage__c + '%');
System.debug('Preço Final Calculado: R$ ' + result.UnitPrice);

if(result.MarginPercentage__c == 45) {
    System.debug('✅ SUCESSO! A lógica de priorização funcionou!');
} else {
    System.debug('❌ A margem veio: ' + result.MarginPercentage__c + '. Verifique se a cidade do Pedido (' + ped.City__c + ') é a mesma da Margem.');
}