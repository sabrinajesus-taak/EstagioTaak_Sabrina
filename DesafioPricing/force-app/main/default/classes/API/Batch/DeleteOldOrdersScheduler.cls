public with sharing class DeleteOldOrdersScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DeleteOldOrdersBatch(), 10);
    }
}