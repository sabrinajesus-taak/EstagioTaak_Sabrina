public class GoalBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, 
            Goal__r.User__c,
            Product__c,
            ProductHierarchy__c,
            PaymentCondition__c,
            RecordType.Name,
            ValueGoal__c,
            GoalCommissionPercentage__c,
            NegotiatedValue__c
            FROM GoalItem__c
        ]);
    }
    
    public void execute(Database.BatchableContext bc, list<GoalItem__c> scope ){
        GoalService service = new GoalService();
        List<GoalItem__c> changedItems = service.calculateRealizedValue(scope);

        System.debug('ENTROU NO EXECUTE');
        System.debug('SCOPE SIZE: ' + scope.size());
        System.debug('Changed Items: ' + changedItems.size());
        
        if(!changedItems.isEmpty()) {
            service.calculateAchievedPercentage(changedItems);
            service.updateGoalItems(changedItems);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
}