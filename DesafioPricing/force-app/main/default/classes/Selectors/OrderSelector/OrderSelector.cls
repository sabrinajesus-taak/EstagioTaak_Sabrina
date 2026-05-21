public class OrderSelector {
    public static Map<Id, Order> getOrdersByIds(Set<Id> setOrderIds) {
        return new Map<Id, Order>([
            SELECT Id, DistributionCenter__c, State__c, City__c, Country__c, AccountId, Status
            FROM Order
            WHERE Id IN :setOrderIds
        ]);
    }
}