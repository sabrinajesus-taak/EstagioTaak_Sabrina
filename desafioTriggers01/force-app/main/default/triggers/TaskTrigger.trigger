trigger TaskTrigger on Task (before insert) {
    // A logica fica na classe
    
    if (Trigger.isBefore && Trigger.isInsert) { //isBefore - antes da criação. isInsert - disparo por criação
        TaskTriggerHandler.validateSingleOpenTask(Trigger.new);
    }
}