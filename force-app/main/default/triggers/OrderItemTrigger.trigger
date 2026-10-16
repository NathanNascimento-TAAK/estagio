trigger OrderItemTrigger on OrderItem (after insert, after update) {
    new OrderItemTriggerHandler().run();
}