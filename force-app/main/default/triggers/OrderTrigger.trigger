trigger OrderTrigger on Order (before update) {
    new OrderTriggerHandler().run();
}