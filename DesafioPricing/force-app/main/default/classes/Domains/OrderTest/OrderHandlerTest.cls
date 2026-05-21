@isTest
public class OrderHandlerTest {
    @TestSetup
    static void setup(){
        TestFactorySObject.createOrderItemScenario();
    }
    
    @isTest
    static void activatedOrder(){
        TestFactorySObject factory = TestFactorySObject.getInstance();

        Order pedido = [SELECT Id FROM ORDER LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        Country__c pais= [SELECT Id FROM Country__c LIMIT 1];
        State__c estado = [SELECT Id FROM State__c LIMIT 1];
        
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = produto.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 1000
            );
        insert item;
        
        City__c cidade2 = (City__c) factory.createSObject(new City__c());
        cidade2.State__c = estado.Id;
        insert cidade2;
        
        pedido.Status = 'Activated';
        update pedido;
        pedido.City__c = cidade2.Id;
        
        Test.startTest();
        try{
            update pedido;
            Assert.fail('O upadte deveria ter sido bloqueado.');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Não é possivel fazer qualquer atualização do PEDIDO após este pedido estar Ativo.'),
            'Mensagem de erro inesperada: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void deleteOrder(){
        TestFactorySObject factory = TestFactorySObject.getInstance();

        Order pedido = [SELECT Id FROM ORDER LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
        Product2Id = produto.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 9000
            );
        insert item;
        
        Test.startTest();
        delete pedido;
        Test.stopTest();
        
        Integer contagemPedido = [SELECT COUNT() FROM Order WHERE Id = :pedido.Id];
        Assert.areEqual(0, contagemPedido, 'O Pedido deveria ter sido deletado.'); 
    }

    @isTest
    static void recalculatePricingOrder(){
        TestFactorySObject factory = TestFactorySObject.getInstance();

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Order pedido = [SELECT Id FROM ORDER LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        Country__c pais= [SELECT Id FROM Country__c LIMIT 1];
        State__c estado = [SELECT Id FROM State__c LIMIT 1];
        estado.Country__c = pais.Id;
        City__c cidadeNova = (City__c) factory.createSObject(new City__c());
        cidadeNova.State__c = estado.Id;
        insert cidadeNova;

        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
            Product2Id = produto.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 9000
        );
        insert item;

        Freight__c frete = (Freight__c) factory.createSObject(new Freight__c());
        frete.Product__c = produto.Id;
        frete.City__c = cidadeNova.Id;
        frete.DistributionCenter__c = dc.Id;
        frete.Status__c = 'Approved';
        frete.FreightValue__c = 400.0;
        insert frete;
        
        Margem__c margem = (Margem__c) factory.createSObject(new Margem__c());
        margem.Product__c = produto.Id;
        margem.Account__c = acc.Id;
        margem.City__c = cidadeNova.Id;
        margem.DistributionCenter__c = dc.Id;
        margem.Status__c = 'Approved';
        margem.MarginValuePercent__c = 13.0;
        insert margem;

        pedido.City__c = cidadeNova.Id;

        Test.startTest();
        update pedido;
        Test.stopTest();

        OrderItem resulTest = [SELECT FreightValue__c, MarginPercentage__c FROM OrderItem WHERE Id = :item.Id];

        System.assertEquals(400.0, resulTest.FreightValue__c, 'O frete deveria ter sido recalculado para 400.0');
        System.assertEquals(13.0, resulTest.MarginPercentage__c, 'A porcentagem da margem deveria ter sido recalculada para 13%.');
    }

    @isTest
    static void deleteOrderActive(){
        Order pedido = [SELECT Id FROM ORDER LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];

        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
            Product2Id = produto.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 6000
        );
        insert item;

        pedido.Status = 'Activated';
        update pedido;

        Test.startTest();
        try{
            delete pedido;
            Assert.fail('O delete no pedido deveria ter sido bloqueado.');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Não é possivel fazer qualquer atualização do PEDIDO após este pedido estar Ativo.'),
            'Mensagem de erro inesperada: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
}