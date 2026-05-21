public class MargemSelector {
    public static List<Margem__c> getMargemApproved() {
        return [
            SELECT Product__c, ProductHierarchy__c, Account__c, AccountGroup__c, City__c, State__c, Country__c, MarginValuePercent__c 
            FROM Margem__c 
            WHERE Status__c = 'Approved' 
        ];
    }
}