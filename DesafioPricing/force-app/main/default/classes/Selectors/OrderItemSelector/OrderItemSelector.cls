public class OrderItemSelector {
    public static List<OrderItem> getOrderItemByIds(Set<Id> orderIds, Set<Id> productIds) {
        return [
        SELECT Id, OrderId, Product2Id
        FROM OrderItem
        WHERE OrderId IN :orderIds
        AND Product2Id IN : productIds
        ];
    }

    public static List<OrderItem> getByOrderIds(Set<Id> orderIds) {
        return [
            SELECT Id 
            FROM OrderItem 
            WHERE OrderId IN :orderIds
        ];
    }
 
}