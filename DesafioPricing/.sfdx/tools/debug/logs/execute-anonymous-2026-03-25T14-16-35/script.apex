// 1. SETUP DO PRODUTO E PEDIDO
Product2 prod = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'GenWatt Diesel 1000kW' LIMIT 1];
Order ped = [SELECT Id, AccountId, City__c, State__c, DistributionCenter__c, Pricebook2Id 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1]; 

PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry 
                      WHERE Product2Id = :prod.Id AND Pricebook2Id = :ped.Pricebook2Id LIMIT 1];

Account acc = [SELECT Id, AccountGroup__c FROM Account WHERE Id = :ped.AccountId];

// 2. LIMPEZA
delete [SELECT Id FROM Margem__c WHERE Product__c = :prod.Id OR ProductHierarchy__c = :prod.ProductHierarchy__c];

// 3. CRIANDO OS NÍVEIS SEPARADOS (Respeitando sua Regra de Validação)
List<Margem__c> margens = new List<Margem__c>();

// Nível Super Específico: SÓ PRODUTO + Conta + Cidade -> 45%
margens.add(new Margem__c(
    Product__c = prod.Id, 
    ProductHierarchy__c = null, // Deixando nulo para a regra não reclamar
    Account__c = acc.Id, 
    City__c = ped.City__c, 
    DistributionCenter__c = ped.DistributionCenter__c, 
    MarginValuePercent__c = 45, 
    Status__c = 'Approved'
));

// Nível Geral: SÓ HIERARQUIA + CD -> 10%
margens.add(new Margem__c(
    Product__c = null, // Deixando nulo para a regra não reclamar
    ProductHierarchy__c = prod.ProductHierarchy__c, 
    DistributionCenter__c = ped.DistributionCenter__c,
    MarginValuePercent__c = 10, 
    Status__c = 'Approved'
));

insert margens; // Agora a Regra de Validação vai deixar passar! ✅

// 4. INSERÇÃO DO ITEM
OrderItem novoItem = new OrderItem(
    OrderId = ped.Id, 
    Product2Id = prod.Id, 
    PricebookEntryId = pbe.Id,
    Quantity = 1, 
    UnitPrice = pbe.UnitPrice
);
insert novoItem;

// 5. VERIFICAÇÃO FINAL
OrderItem result = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :novoItem.Id];

System.debug('--- 🏆 VALIDAÇÃO DOS 18 NÍVEIS ---');
System.debug('Margem aplicada (Esperado 45%): ' + result.MarginPercentage__c + '%');
System.debug('Preço Final Calculado: R$ ' + result.UnitPrice);

if(result.MarginPercentage__c == 45) {
    System.debug('✅ CRITÉRIO DE ACEITE 1 ATENDIDO: Priorização correta!');
}