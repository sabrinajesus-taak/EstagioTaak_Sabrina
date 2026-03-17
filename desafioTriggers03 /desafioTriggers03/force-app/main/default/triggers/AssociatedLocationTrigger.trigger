trigger AssociatedLocationTrigger on AssociatedLocation (after insert, after update, after delete) {
    new AssociatedLocationTriggerHandler().run();
}