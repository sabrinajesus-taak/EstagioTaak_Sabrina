Order ped = [SELECT Id, AccountId, City__c, State__c, Country__c, DistributionCenter__c 
             FROM Order 
             WHERE City__c != null AND DistributionCenter__c != null LIMIT 1];

// 2. PEGANDO AS OUTRAS PEÇAS BASEADO NO PEDIDO
Id idA = ped.AccountId;
Account acc = [SELECT Id, AccountGroup__c FROM Account WHERE Id = :idA];
Product2 prod = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1];

// Limpeza
delete [SELECT Id FROM Margem__c WHERE Product__c = :prod.Id OR ProductHierarchy__c = :prod.ProductHierarchy__c];

// Criar margens aprovadas
List<Margem__c> margensParaTestar = new List<Margem__c>();

// Margem A: Super específica (Produto + Cliente + Cidade) -> 30%
margensParaTestar.add(new Margem__c(
    Product__c = prod.Id, 
    Account__c = acc.Id, 
    City__c = ped.City__c, 
    DistributionCenter__c = ped.DistributionCenter__c, 
    MarginValuePercent__c = 30, 
    Status__c = 'Approved' // O critério de aceite pede que seja Aprovada
));

// Margem B: Geral (Só a Hierarquia do produto) -> 10%
margensParaTestar.add(new Margem__c(
    ProductHierarchy__c = prod.ProductHierarchy__c, 
    DistributionCenter__c = ped.DistributionCenter__c,
    MarginValuePercent__c = 10, 
    Status__c = 'Approved'
));

insert margensParaTestar; 

//criação do item pedido
OrderItem novoItem = new OrderItem(
    OrderId = ped.Id, 
    Product2Id = prod.Id, 
    Quantity = 1, 
    UnitPrice = 1
);
insert novoItem;

// 4. VERIFICAÇÃO: Vamos perguntar para o banco: "Ei, que margem você colocou no item?"
OrderItem itemCalculado = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :novoItem.Id];

System.debug('>>> RESULTADO DO TESTE <<<');
System.debug('Margem aplicada: ' + itemCalculado.MarginPercentage__c + '%');
System.debug('Preço Unitário final: R$ ' + itemCalculado.UnitPrice);

// Se a margem for 30%, o sistema provou que é inteligente e pegou a MAIS específica!