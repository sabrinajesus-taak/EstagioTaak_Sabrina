public class FreightService{
    
    private static void addKeys(List<String> keys, Id productId, List<Id> locationsIds) {
        for (Id iLocations : locationsIds) {
            if (productId != null && iLocations != null) {
                keys.add(productId + '_' + iLocations);
            }
        }
    }
    
    private static List<String> buildFreightKeys(OrderItem item, Order order, Id hierarchyId) {
        List<String> keys = new List<String>();
        
        List<Id> productsIds = new List<Id>{ item.Product2Id, hierarchyId };
        List<Id> locationsIds = new List<Id>{ order.City__c, order.State__c, order.Country__c };
        
        for (Id iProduct2 : productsIds) {
            addKeys(keys, iProduct2, locationsIds);
        }
        
        return keys;
    }
    
    public static Decimal findFreight(OrderItem item, Order order, Map<String, Freight__c> mapFreight, Id hierarchyId){
        List<String> keys = buildFreightKeys(item, order, hierarchyId);
        
        for (String iKey: keys) {
            if (mapFreight.containsKey(iKey)) {
                return mapFreight.get(iKey).FreightValue__c;
            }
        }
        return 0;
    }
}