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
}