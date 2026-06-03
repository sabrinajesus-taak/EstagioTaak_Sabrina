public class DevUserTriggerHandler extends TriggerHandler {

    private List<DevUser__c> newRecords;
    private Map<Id, DevUser__c> oldRecordsMap;

    public DevUserTriggerHandler() {
        super('DevUserTriggerHandler');
        this.newRecords = (List<DevUser__c>) Trigger.new;
        this.oldRecordsMap = (Map<Id, DevUser__c>) Trigger.oldMap;
    }

    protected override void afterInsert() {
        usersLoginCheck();
    }

    protected override void afterUpdate() {
        usersLoginChange();
    }

    private void usersLoginCheck(){

        Set<Id> idsToProcess = new Set<Id>();

        for(DevUser__c iDevUser : newRecords) {
            if(iDevUser.Login__c != null) {
                idsToProcess.add(iDevUser.Id);
            }
        }

        if(!idsToProcess.isEmpty()){
            processBatch(idsToProcess);
        }

    }

    private void usersLoginChange(){

        Set<Id> idsToProcess = new Set<Id>();

        for(DevUser__c iDevUserNew : newRecords) {
            //registro antigo com mesmo id do registro novo
            DevUser__c iDevUserOld = oldRecordsMap.get(iDevUserNew.Id);
            if(iDevUserOld != null && iDevUserNew.Login__c != iDevUserOld.Login__c) {
                idsToProcess.add(iDevUserNew.Id);
            }
        }

        if(!idsToProcess.isEmpty()){
            processBatch(idsToProcess);
        }
    }

    private void processBatch(Set<Id> idsToProcess) {
        Database.executeBatch(new DevUserBatch(idsToProcess));
    }
}