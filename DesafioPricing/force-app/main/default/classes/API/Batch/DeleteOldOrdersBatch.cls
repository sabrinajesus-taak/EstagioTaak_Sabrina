public with sharing class DeleteOldOrdersBatch implements Database.Batchable<SObject>{
    
    private static final Set<String> draftStatuses = new Set<String>{
        'New',
        'PendingApproval',
        'IntegrationError'
    };
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        DevParameters__mdt devParameters = DevParameters__mdt.getInstance('MaxNumberMonthsOrder');
        
        Integer valueMonth = devParameters != null ? Integer.valueOf(devParameters.Value__c) : 6;
        
        Date limitDate = Date.today().addMonths(valueMonth * -1);
        // teste
        // Date limitDate = Date.today().addMonths(0 * -1);
        
        return Database.getQueryLocator([
            SELECT Id, Status 
            FROM Order 
            WHERE Status IN :draftStatuses AND CreatedDate <= :limitDate
        ]);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Order> orderList){
        
        Set<Id> orderIdsToDelete = new Set<Id>();
        List<IntegrationLog__c> logIdsToDelete = new List<IntegrationLog__c>();
        
        for(Order iOrder : orderList){
            orderIdsToDelete.add(iOrder.Id);
        }
        
        for(IntegrationLog__c iIntegrationLog : [
            SELECT Id 
            FROM IntegrationLog__c 
            WHERE Order__c IN :orderIdsToDelete
        ]){
            logIdsToDelete.add(iIntegrationLog);
        }
        
        Database.delete(logIdsToDelete, false);
        
        Database.delete(orderList, false);
    }
    
    public void finish(Database.BatchableContext bc){}
}