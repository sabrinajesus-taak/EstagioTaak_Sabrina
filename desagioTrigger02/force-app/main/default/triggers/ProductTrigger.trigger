trigger ProductTrigger on Product2 (after insert) {
    //verifica se estamos depois da inserção
    if (Trigger.isAfter && Trigger.isInsert) {
        // Chama o método 
        ProductTriggerHandle.createStandardPricebookEntries(Trigger.new);
    }
}