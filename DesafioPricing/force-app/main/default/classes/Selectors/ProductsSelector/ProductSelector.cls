public class ProductSelector {
    public static Map<Id, Product2> getProductByIds(Set<Id> ids) {
        return new Map<Id, Product2>([
            SELECT Id, ProductionCost__c, ProductHierarchy__c
            FROM Product2
            WHERE Id IN :ids
        ]);
    }
}