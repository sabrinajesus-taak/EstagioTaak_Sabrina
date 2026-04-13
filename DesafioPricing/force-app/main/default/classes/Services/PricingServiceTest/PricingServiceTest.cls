@isTest
public class PricingServiceTest {
    @TestSetup
    static void setup(){
        TestFactorySObject.createPrincingScenario();
    }
    @isTest
    static void testFreightMargin(){
        TestFactorySObject factory = TestFactorySObject.getInstance();
        
        Country__c pais = [SELECT Id FROM Country__c LIMIT 1];
        ProductHierarchy__c h = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Order pedido = [SELECT Id FROM Order LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        AccountGroup__c acg = [SELECT Id FRom AccountGroup__c LIMIT 1];
        
        Freight__c frete = (Freight__c) factory.createSObject(new Freight__c());
        frete.ProductHierarchy__c = h.Id;
        frete.Country__c = pais.Id;
        frete.DistributionCenter__c = dc.Id;
        frete.Status__c = 'Approved';
        frete.FreightValue__c = 1500.0;
        insert frete;
        
        Margem__c margem = (Margem__c) factory.createSObject(new Margem__c());
        margem.ProductHierarchy__c = h.Id;
        margem.AccountGroup__c = acg.Id;
        margem.Country__c = pais.Id;
        margem.DistributionCenter__c = dc.Id;
        margem.Status__c = 'Approved';
        margem.MarginValuePercent__c = 25.0;
        insert margem;
        
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = prod.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 2,
        UnitPrice = 5000
            );
        
        Test.startTest();
        insert item;
        Test.stopTest();
        
        OrderItem itemResult = [SELECT UnitPrice, FreightValue__c, MarginPercentage__c FROM OrderItem WHERE Id = :item.Id];
        
        System.assertEquals(1500.0, itemResult.FreightValue__c, 'O Frete deveria ser 1500.0.');
        System.assertEquals(25.0, itemResult.MarginPercentage__c, 'O percentual da Margem deveria ser 25%.');
        System.assertEquals(414562.50, itemResult.UnitPrice, 'O cálculo do Preço Final (Custo + Frete + Imposto + Margem) está incorreto.');
    }
    
    @isTest
    static void testFreightMarginWithZero(){
        TestFactorySObject factory = TestFactorySObject.getInstance();
        
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Order pedido = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        City__c c = [SELECT Id FROM City__c LIMIT 1];
        
        ProductHierarchy__c novoH = (ProductHierarchy__c) factory.createSObject(new ProductHierarchy__c());
        
        Product2 produtoNovo = (Product2) factory.createSObject(new Product2());
        produtoNovo.ProductHierarchy__c = novoH.Id;
        insert produtoNovo;
        
        AccountGroup__c novoAcg = (AccountGroup__c) factory.createSObject(new AccountGroup__c());
        insert novoAcg;
        
        Account accNova = (Account) factory.createSObject(new Account());
        accNova.AccountGroup__c = novoAcg.Id;
        insert accNova;
        
        
        Freight__c frete = (Freight__c) factory.createSObject(new Freight__c());
        frete.Product__c = produtoNovo.Id;
        frete.City__c = c.Id;
        frete.DistributionCenter__c = dc.Id;
        frete.Status__c = 'Approved';
        frete.FreightValue__c = 900.0;
        insert frete;
        
        Margem__c margem = (Margem__c) factory.createSObject(new Margem__c());
        margem.Product__c = produtoNovo.Id;
        margem.Account__c = accNova.Id;
        margem.City__c = c.Id;
        margem.DistributionCenter__c = dc.Id;
        margem.Status__c = 'Approved';
        margem.MarginValuePercent__c = 10.0;
        insert margem;
        
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = produtoNovo.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 2,
        UnitPrice = 5000
            );
        
        Test.startTest();
        try {
            insert item;
            Assert.fail('Deveria ter barrado porque não encontrou parâmetros válidos');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.'),
            'Mensagem de erro inesperada: ' + e.getMessage());
        }
        Test.stopTest();
    }
}