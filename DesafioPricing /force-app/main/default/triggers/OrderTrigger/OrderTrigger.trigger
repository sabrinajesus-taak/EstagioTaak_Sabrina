trigger OrderTrigger on Order (before update, before delete ) {
    new OrderHandler().run();
}