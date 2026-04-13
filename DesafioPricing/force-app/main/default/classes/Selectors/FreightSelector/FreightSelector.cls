public class FreightSelector {
    public static List<Freight__c> getFreightApproved(){
        return [
            SELECT Product__c, City__c, State__c, Country__c, DistributionCenter__c, FreightValue__c, ProductHierarchy__c
            FROM Freight__c
            WHERE Status__c = 'Approved' 
        ];
    }
}