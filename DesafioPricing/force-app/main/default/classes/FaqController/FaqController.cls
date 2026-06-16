public with sharing class FaqController {

    @AuraEnabled
    public static List<FAQ__c> searchFaq(String termo) {
        String palavra = '%' + termo + '%';
        List<FAQ__c> listFaqs = [SELECT Id, Question__c, Answer__c FROM FAQ__c WHERE Question__c LIKE :palavra];

        return listFaqs;
    }

    // public class FaqResult {
    //     @AuraEnabled public String id;

    // }
}