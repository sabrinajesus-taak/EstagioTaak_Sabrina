trigger OrderTrigger on Order (before insert, before update, after update, before delete ) {
    new OrderHandler().run();
}