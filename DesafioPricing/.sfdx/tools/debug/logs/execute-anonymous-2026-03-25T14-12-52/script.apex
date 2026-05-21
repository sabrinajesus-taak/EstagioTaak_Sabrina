// 1. BUSCA O PRODUTO
Product2 prod = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1];

// 2. BUSCA O PEDIDO QUE VOCÊ ACABOU DE CRIAR
// (Ele vai pegar o mais recente que tem Cidade e CD)
Order ped = [SELECT Id, AccountId, City__c, State__c, DistributionCenter__c, Pricebook2Id 
             FROM Order 
             WHERE City__c != null AND DistributionCenter__c != null 
             ORDER BY CreatedDate DESC LIMIT 1];

// 3. BUSCA O PREÇO DO PRODUTO (O tal do PricebookEntry que deu erro)
// Vamos procurar o preço desse produto na tabela que está no seu pedido
PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry 
                      WHERE Product2Id = :prod.Id 
                      AND Pricebook2Id = :ped.Pricebook2Id 
                      AND IsActive = true LIMIT 1];

Account acc = [SELECT Id, AccountGroup__c FROM Account WHERE Id = :ped.AccountId];

// 4. LIMPEZA E CRIAÇÃO DAS MARGENS
delete [SELECT Id FROM Margem__c WHERE Product__c = :prod.Id OR ProductHierarchy__c = :prod.ProductHierarchy__c];

List<Margem__c> margens = new List<Margem__c>();
margens.add(new Margem__c(
    Product__c = prod.Id, Account__c = acc.Id, City__c = ped.City__c, 
    DistributionCenter__c = ped.DistributionCenter__c, MarginValuePercent__c = 30, Status__c = 'Approved'
));
margens.add(new Margem__c(
    ProductHierarchy__c = prod.ProductHierarchy__c, DistributionCenter__c = ped.DistributionCenter__c,
    MarginValuePercent__c = 10, Status__c = 'Approved'
));
insert margens;

// 5. INSERÇÃO DO ITEM (Agora com o PBE Id para não dar erro!)
OrderItem novoItem = new OrderItem(
    OrderId = ped.Id, 
    Product2Id = prod.Id, 
    PricebookEntryId = pbe.Id, // <--- O SALVADOR DA PÁTRIA!
    Quantity = 1, 
    UnitPrice = pbe.UnitPrice // Preço base da tabela
);
insert novoItem;

// 6. VERIFICAÇÃO NO LOG
OrderItem result = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :novoItem.Id];
System.debug('--- ✅ FINALMENTE! SUCESSO NO TESTE ---');
System.debug('Margem Escolhida: ' + result.MarginPercentage__c + '%');
System.debug('Preço com Margem e Imposto: R$ ' + result.UnitPrice);