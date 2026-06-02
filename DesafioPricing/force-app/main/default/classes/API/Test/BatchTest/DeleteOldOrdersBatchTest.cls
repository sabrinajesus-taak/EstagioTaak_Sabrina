@isTest
public with sharing class DeleteOldOrdersBatchTest {
    
    @isTest
    static void testDeleteOldNewOrderLog(){
        
        Order order = TestFactorySObject.createPrincingScenario();
        
        Test.setCreatedDate(
            order.Id,
            Datetime.now().addMonths(-7));

        IntegrationLog__c log = new IntegrationLog__c(
            Name = 'Teste',
            Order__c = order.Id);
        
        insert log;

        Test.startTest();
        Database.executeBatch(new DeleteOldOrdersBatch(),10);
        Test.stopTest();

        System.AssertEquals(0, [SELECT count() FROM Order WHERE Id = :order.Id], 'O pedido deveria ter sido deletado');
        System.AssertEquals(0, [SELECT count() FROM IntegrationLog__c WHERE Id = :log.Id], 'O log relacionado ao pedido deveria ter sido deletado');
    }

    @isTest
    static void testDeleteOldApprovedOrder(){
        Order order = TestFactorySObject.createOrderItemScenario();

        Test.setCreatedDate(
            order.Id,
            Datetime.now().addMonths(-7));

        order.Status = 'Approved';
        update order;

        IntegrationLog__c log = new IntegrationLog__c(
            Name = 'Teste',
            Order__c = order.Id);
        
        insert log;

        Test.startTest();
        Database.executeBatch(new DeleteOldOrdersBatch(),10);
        Test.stopTest();

        System.AssertEquals(1, [SELECT count() FROM Order WHERE Id = :order.Id], 'O pedido não deveria ser deletado por estar com status Approved');
        System.AssertEquals(1, [SELECT count() FROM IntegrationLog__c WHERE Id = :log.Id], 'O log relacionado ao pedido não deveria ter sido deletado');
    }

    @isTest
    static void testDeleteOldIntegratedOrder(){
        Order order = TestFactorySObject.createOrderItemScenario();
        
        Test.setCreatedDate(
            order.Id,
            Datetime.now().addMonths(-7));

        order.Status = 'Integrated';
        update order;

        IntegrationLog__c log = new IntegrationLog__c(
            Name = 'Teste',
            Order__c = order.Id);
        
        insert log;

        Test.startTest();
        Database.executeBatch(new DeleteOldOrdersBatch(),10);
        Test.stopTest();

        System.AssertEquals(1, [SELECT count() FROM Order WHERE Id = :order.Id], 'O pedido não deveria ser deletado por estar com status Integrated');
        System.AssertEquals(1, [SELECT count() FROM IntegrationLog__c WHERE Id = :log.Id], 'O log relacionado ao pedido não deveria ter sido deletado');
    }

    @isTest
    static void testDeleteOldNewOrder(){
        Order order = TestFactorySObject.createPrincingScenario();

        Test.setCreatedDate(
            order.Id,
            Datetime.now().addMonths(-7));

        Test.startTest();
        Database.executeBatch(new DeleteOldOrdersBatch(),10);
        Test.stopTest();

        System.AssertEquals(0, [SELECT count() FROM Order WHERE Id = :order.Id], 'O pedido deveria ter sido deletado');
    }
}