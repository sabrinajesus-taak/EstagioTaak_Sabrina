trigger OrderTrigger on Order (before update, after update, before delete ) {
    new OrderHandler().run();
}