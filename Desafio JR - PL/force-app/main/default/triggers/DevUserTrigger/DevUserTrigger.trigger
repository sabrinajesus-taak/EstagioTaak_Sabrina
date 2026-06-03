trigger DevUserTrigger on DevUser__c (after insert, after update) {
    new DevUserTriggerHandler().run();
}