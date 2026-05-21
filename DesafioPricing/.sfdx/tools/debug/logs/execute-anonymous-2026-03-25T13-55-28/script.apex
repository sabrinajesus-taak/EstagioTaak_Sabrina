Product2 prod = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1];
Id idCD = [SELECT Id FROM DistributionCenter__c LIMIT 1].Id;
Id idCity = [SELECT Id FROM City__c LIMIT 1].Id;
Id idState = [SELECT Id FROM State__c LIMIT 1].Id;

// criação da conta e pedido novo
Account acc = new Account(Name = 'Cliente Teste Margem', AccountGroup__c = 'Grupo A'); 
insert acc;

Order ped = new Order(
    AccountId = acc.Id, 
    EffectiveDate = Date.today(), 
    Status = 'Draft', 
    Pricebook2Id = Test.getStandardPricebookId(), // Garante que o pedido aceite itens
    DistributionCenter__c = idCD,
    City__c = idCity,
    State__c = idState
);
insert ped;

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