public class TaxSelector {
    public static List<Tax__c> getTaxApproved(){
        return [
            SELECT Product__c, State__c, DistributionCenter__c, TaxRate__c
            FROM Tax__c
            WHERE Status__c = 'Approved'
        ];
    }
}