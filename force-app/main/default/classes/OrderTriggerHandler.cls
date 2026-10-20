public with sharing class OrderTriggerHandler extends TriggerHandler {
    public override void beforeUpdate() {
        Map<Id, Order> oldOrders = (Map<Id, Order>) Trigger.oldMap;
        for(Order newOrder : (List<Order>) Trigger.new) {
            Order oldOrder = oldOrders.get(newOrder.Id);
            if(oldOrder.Status == 'Activated') {
                newOrder.addError('Não é possivel alterar um pedido já ativo!');
            }
            else if(newOrder.AccountId != oldOrder.AccountId) {
                newOrder.addError('Não é possivel alterar a conta do pedido após sua criação');
            }
        }
    }
}