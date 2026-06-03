public with sharing class DevUserBatch implements Database.Batchable<SObject> ,  Database.AllowsCallouts {
    
    private Set<Id> idsToProcess;
    
    public DevUserBatch(Set<Id> idsToProcess) {
        this.idsToProcess = idsToProcess;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Login__c FROM DevUser__c WHERE Id IN :idsToProcess]);
    }
    
    public void execute(Database.BatchableContext bc, List<DevUser__c> records){
        List<DevUser__c> usersToUpdate = new List<DevUser__c>();
        for(DevUser__c iDevUser : records) {
            try{
                if(iDevUser.Login__c == null) {
                    continue; //pula para o próximo registro se o login for nulo
                }
                GitHubUserDTO DTO = GitHubService.buscarUsuario(iDevUser.Login__c);
                iDevUser.ExternalId__c = DTO.id;
                iDevUser.Type__c = DTO.type;
                iDevUser.Bio__c = DTO.bio;
                usersToUpdate.add(iDevUser);

            } catch(Exception e) {
                iDevUser.ExternalId__c = null;
                iDevUser.Type__c = null;
                iDevUser.Bio__c = null;
                usersToUpdate.add(iDevUser);
                System.debug('Error processing user with Id: '+ iDevUser.Id+ '. Error: '+ e.getMessage());
            }
            
        }
        
        if(!usersToUpdate.isEmpty()){
            update usersToUpdate;
        }
        
    }
    
    public void finish(Database.BatchableContext bc){} //por enquano vazio
}