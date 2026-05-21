// 1. BUSCA O PRODUTO E O PEDIDO QUE VOCÊ CRIOU MANUALMENTE
Product2 prod = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'GenWatt Diesel 1000kW' LIMIT 1];
Order ped = [SELECT Id, AccountId, City__c, State__c, DistributionCenter__c, Pricebook2Id 
             FROM Order WHERE OrderNumber = '00000100' LIMIT 1]; // Usei o número do seu print!

// Busca o preço de tabela (PBE) para não dar erro de Insert
PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry 
                      WHERE Product2Id = :prod.Id AND Pricebook2Id = :ped.Pricebook2Id LIMIT 1];

Account acc = [SELECT Id, AccountGroup__c FROM Account WHERE Id = :ped.AccountId];

// 2. LIMPEZA E CRIAÇÃO DAS MARGENS DE TESTE (CENÁRIO DE CONFLITO)
delete [SELECT Id FROM Margem__c WHERE Product__c = :prod.Id OR ProductHierarchy__c = :prod.ProductHierarchy__c];

List<Margem__c> margens = new List<Margem__c>();

// Nível Super Específico (Produto + Conta + Cidade) -> 45%
margens.add(new Margem__c(
    Product__c = prod.Id, 
    Account__c = acc.Id, 
    City__c = ped.City__c, 
    DistributionCenter__c = ped.DistributionCenter__c, 
    MarginValuePercent__c = 45, 
    Status__c = 'Approved'
));

// Nível Geral (Hierarquia do Produto) -> 10%
margens.add(new Margem__c(
    ProductHierarchy__c = prod.ProductHierarchy__c, 
    DistributionCenter__c = ped.DistributionCenter__c,
    MarginValuePercent__c = 10, 
    Status__c = 'Approved'
));

insert margens;

// 3. INSERÇÃO DO ITEM VIA CÓDIGO (Para provar a automação)
OrderItem novoItem = new OrderItem(
    OrderId = ped.Id, 
    Product2Id = prod.Id, 
    PricebookEntryId = pbe.Id,
    Quantity = 1, 
    UnitPrice = pbe.UnitPrice
);
insert novoItem;

// 4. VERIFICAÇÃO FINAL
OrderItem result = [SELECT MarginPercentage__c, UnitPrice, FreightValue__c FROM OrderItem WHERE Id = :novoItem.Id];

System.debug('--- 🏆 VALIDAÇÃO DOS 18 NÍVEIS ---');
System.debug('Margem aplicada (Esperado 45%): ' + result.MarginPercentage__c + '%');
System.debug('Preço Final Calculado: R$ ' + result.UnitPrice);

if(result.MarginPercentage__c == 45) {
    System.debug('✅ CRITÉRIO DE ACEITE 1 ATENDIDO: O sistema priorizou a margem mais específica!');
}