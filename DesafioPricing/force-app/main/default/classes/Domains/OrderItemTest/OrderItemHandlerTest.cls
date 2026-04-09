@isTest
public class OrderItemHandlerTest {
    @isTest
    static void pricingOrderItemTest(){
        TestFactorySObject factory = TestFactorySObject.getInstance();

        ProductHierarchy__c hier = (ProductHierarchy__c) factory.createSObject(new ProductHierarchy__c());
        insert hier;

        Product2 prod = (Product2) factory.createSObject(new Product2(ProductHierarchy__c = hier.Id));
        insert prod;
        
    }
}