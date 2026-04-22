@isTest
public class OrderItemHandlerTest {
    @TestSetup
    static void setup(){
        TestFactorySObject.createOrderItemScenario();
    }
    
    @isTest
    static void pricingOrderItemTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c dc = [SELECT Id, State__c, City__c, Country__c FROM DistributionCenter__c LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        Order pedido = new Order(
            AccountId = acc.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = stdPricebookId,
        DistributionCenter__c = dc.Id,
        State__c = dc.State__c,
        City__c = dc.City__c,
        Country__c = dc.Country__c
            );
        insert pedido;
        
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = produto.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 100
            );
        
        Test.startTest();
        insert item;
        Test.stopTest();
        
        OrderItem itemResult = [SELECT UnitPrice, MarginPercentage__c, TaxPercentage__c, FreightValue__c FROM OrderItem WHERE Id = :item.Id];
        
        System.assertEquals(380385.50, itemResult.UnitPrice, 'O cálculo final está errado');
        System.assertEquals(10.0, itemResult.TaxPercentage__c, 'A porcentagem do imposto deveria ser 10%.');
        System.assertEquals(15.0, itemResult.MarginPercentage__c, 'A porcentagem da margem dveria ser 15%.');
        System.assertEquals(700.0, itemResult.FreightValue__c, 'O valor do frete deveria ser de 700.0.');
    }
    
    @isTest
    static void shouldNotAllowZeroQuantity() {
        Order pedido = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        
        OrderItem itemErro = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = prod.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 0,
        UnitPrice = 0
            );
        
        Test.startTest();
        try {
            insert itemErro;
            Assert.fail('Deveria ter lançado um erro de validação');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Não é possível cadastrar produtos'), 'Mensagem de erro incorreta');
        }
        Test.stopTest();
    }
    
    @isTest
    static void checkExistingProductInOrder(){
        Order pedido = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = produto.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 100
            );
        insert item;
        
        OrderItem item2 = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = produto.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 100
            );
        
        Test.startTest();
        try{
            insert item2;
            Assert.fail('Deveria ter barrado a duplicidade');
        } catch (DmlException e) {
            String mensagem = e.getMessage();
            Assert.isTrue(mensagem.contains('Este produto já foi adicionado a este pedido. Altere a quantidade do item existente.'),
            'A mensagem de erro retornada foi: ' + mensagem);
        }
        Test.stopTest();
    }
    
    @isTest
    static void shouldNotAllowChangesOnActiveOrder(){
        Order pedido = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = produto.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 100
            );
        insert item;
        
        pedido.Status = 'Activated';
        update pedido;
        item.Quantity = 10;
        
        Test.startTest();
        try{
            update item;
            Assert.fail('Deveria não ter alterado a quantidade.');
        } catch (DmlException e) {
            String mensagem = e.getMessage();
            Assert.isTrue(mensagem.contains('Não é possivel fazer qualquer alteração dos ITENS após o pedido ser marcado como Ativo'),
            'A mensagem de erro retornada foi: ' + mensagem);
        }
        Test.stopTest();
    }
    
    @isTest
    static void deleteOrderItemDraft() {
        Order pedido = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = produto.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 100
            );
        insert item;
        
        Test.startTest();
        delete item;
        Test.stopTest();
        
        Integer countItem = [SELECT COUNT() FROM OrderItem WHERE Id = :item.Id];
        System.assertEquals(0, countItem, 'O item deveria ter sido deletado com sucesso.');
    }
    
    @isTest
    static void bulkOrderItemPricing(){
        TestFactorySObject factory = TestFactorySObject.getInstance();
        
        Order pedido = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbeBase = [SELECT Pricebook2Id FROM PricebookEntry LIMIT 1];
        State__c estado = [SELECT Id FROM State__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        List<ProductHierarchy__c> hierarquias = new List<ProductHierarchy__c>();
        for (Integer i = 0; i < 200; i++) {
            hierarquias.add((ProductHierarchy__c) factory.createSObject(new ProductHierarchy__c(
                Code__c = 'HB' + i
                )));
        }
        insert hierarquias;
        
        List<Product2> produtos = new List<Product2>();
        for (Integer i = 0; i< 200; i++){
            produtos.add((Product2) factory.createSObject(new Product2(
                UniqueCode__c = 'TB' + i,
                ProductHierarchy__c = hierarquias[i].Id
                )));
        }
        insert produtos;
        
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        List<Freight__c> fretes = new List<Freight__c>();
        List<Margem__c> margins = new List<Margem__c>();
        List<Tax__c> impostos = new List<Tax__c>();
        for (Product2 p : produtos){
            pbes.add((PricebookEntry) factory.createSObject(new PricebookEntry(
                Pricebook2Id = pbeBase.Pricebook2Id,
            Product2Id = p.Id,
            UnitPrice = 1000,
            IsActive = true
                )));
            
            fretes.add((Freight__c) factory.createSObject(new Freight__c(
                Product__c = p.Id,
            State__c = estado.Id,
            DistributionCenter__c = dc.Id,
            Status__c = 'Approved',
            FreightValue__c = 500.0
                )));
            
            margins.add((Margem__c) factory.createSObject(new Margem__c(
                Product__c = p.Id,
            Account__c = acc.id,
            State__c = estado.Id,
            DistributionCenter__c = dc.Id,
            Status__c = 'Approved',
            MarginValuePercent__c = 12.0
                )));
            
            impostos.add((Tax__c) factory.createSObject(new Tax__c(
                DistributionCenter__c = dc.Id,
            Product__c = p.Id,
            State__c = estado.Id,
            Status__c = 'Approved',
            TaxRate__c = 8.0
                )));
        }
        insert pbes;
        insert fretes;
        insert margins;
        insert impostos;
        
        List<OrderItem> itens = new List<OrderItem>();
        for(PricebookEntry pbe : pbes){
            itens.add(new OrderItem(
                OrderId = pedido.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            Quantity = 1,
            UnitPrice = 3000
                ));
        }
        
        Test.startTest();
        insert itens;
        Test.stopTest();
        
        List<OrderItem> resultados = [SELECT Id, UnitPrice, FreightValue__c, MarginPercentage__c, TaxPercentage__c, ProductionCost__c FROM OrderItem WHERE OrderId = :pedido.Id];
        
        Assert.areEqual(200, resultados.size(), 'Deveria ter inserido exatamente 200 itens.');
        
        Decimal valorEsperado = 363484.80;
        
        for(OrderItem o : resultados) {
            Assert.areEqual(500.0, o.FreightValue__c, 'O Frete de um dos itens no lote está incorreto.');
            Assert.areEqual(12.0, o.MarginPercentage__c, 'A Margem de um dos itens no lote está incorreta.');
            Assert.areEqual(8.0, o.TaxPercentage__c, 'O Imposto de um dos itens no lote está incorreto.');
            Assert.areEqual(valorEsperado, o.UnitPrice, 'O cálculo de UnitPrice falhou em um dos itens do lote de 200.');
        }
    }
}