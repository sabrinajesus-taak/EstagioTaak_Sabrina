// 1. BUSCA DO PRODUTO (O único que precisamos ter certeza do nome)
List<Product2> prods = [SELECT Id, ProductHierarchy__c FROM Product2 WHERE Name = 'Colheitadeira S700' LIMIT 1];

if(prods.isEmpty()) {
    System.debug('❌ ERRO: Não achei o produto Colheitadeira S700. Verifique o nome!');
} else {
    Product2 prod = prods[0];
    
    // 2. BUSCA DE UM PEDIDO QUALQUER QUE JÁ TENHA CIDADE E CD
    // Assim não precisamos criar nada do zero!
    List<Order> peds = [SELECT Id, AccountId, City__c, State__c, Country__c, DistributionCenter__c 
                        FROM Order 
                        WHERE City__c != null AND DistributionCenter__c != null 
                        LIMIT 1];

    if(peds.isEmpty()) {
        System.debug('❌ ERRO: Não achei nenhum Pedido pronto com Cidade/CD no banco.');
    } else {
        Order ped = peds[0];
        Account acc = [SELECT Id, AccountGroup__c FROM Account WHERE Id = :ped.AccountId];

        // 3. LIMPEZA E CRIAÇÃO DAS MARGENS DE TESTE
        delete [SELECT Id FROM Margem__c WHERE Product__c = :prod.Id OR ProductHierarchy__c = :prod.ProductHierarchy__c];

        List<Margem__c> margens = new List<Margem__c>();
        // Margem A: Específica (30%)
        margens.add(new Margem__c(
            Product__c = prod.Id, Account__c = acc.Id, City__c = ped.City__c, 
            DistributionCenter__c = ped.DistributionCenter__c, MarginValuePercent__c = 30, Status__c = 'Approved'
        ));
        // Margem B: Geral (10%)
        margens.add(new Margem__c(
            ProductHierarchy__c = prod.ProductHierarchy__c, DistributionCenter__c = ped.DistributionCenter__c,
            MarginValuePercent__c = 10, Status__c = 'Approved'
        ));
        insert margens;

        // 4. INSERÇÃO DO ITEM (Onde a sua Trigger trabalha)
        OrderItem novoItem = new OrderItem(
            OrderId = ped.Id, Product2Id = prod.Id, Quantity = 1, UnitPrice = 1
        );
        insert novoItem;

        // 5. VERIFICAÇÃO NO LOG
        OrderItem result = [SELECT MarginPercentage__c, UnitPrice FROM OrderItem WHERE Id = :novoItem.Id];
        System.debug('--- ✅ SUCESSO NO TESTE ---');
        System.debug('Margem que a Trigger escolheu: ' + result.MarginPercentage__c + '%');
        System.debug('Preço final calculado: R$ ' + result.UnitPrice);
    }
}
