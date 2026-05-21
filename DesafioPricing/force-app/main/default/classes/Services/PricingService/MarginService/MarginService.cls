public class MarginService {
    
    private static void addKeys(List<String> keys, Id productId, Id accountId, List<Id> locationsIds) {
        for (Id iLocations : locationsIds) {
            if (productId != null && accountId != null && iLocations != null) {
                keys.add(productId + '_' + accountId + '_' + iLocations);
            }
        }
    }
    
    private static List<String> buildMarginKeys(OrderItem item, Order order, Id hierarchyId, Id accountId, Id accountGroupId) {
        List<String> keys = new List<String>();
        
        List<Id> custumerIds = new List<Id>{accountId, accountGroupId};
        List<Id> productsIds = new List<Id>{ item.Product2Id, hierarchyId };
        List<Id> locationsIds = new List<Id>{ order.City__c, order.State__c, order.Country__c };
        
        for (Id iProduct2 : productsIds) {
            for (Id iaccountId: custumerIds) {
                addKeys(keys, iProduct2, iaccountId, locationsIds);
            }
        }
        
        return keys;
    }
    
    public static Margem__c findMargin(OrderItem item, Order order, Map<String, Margem__c> mapMargin, Id hierarchyId, Account custumer){
        List<String> keys = buildMarginKeys(item, order, hierarchyId, order.AccountId, custumer.AccountGroup__c);
        
        for (String iKey: keys) {
            if (mapMargin.containsKey(iKey)) {
                return mapMargin.get(iKey);
            }
        }
        return null;
    }
    
}