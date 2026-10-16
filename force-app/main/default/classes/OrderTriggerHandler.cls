public with sharing class OrderTriggerHandler extends TriggerHandler {
    public override void beforeUpdate() {
        Map<Id, Order> oldOrdersById = Trigger.oldMap;
        for(Order newOrder : (List<Order>) Trigger.new) {
            Order oldOrder = oldOrdersById.get(newOrder.Id);
            if(oldOrder.Status == 'Activated') {
                newOrder.addError('Não é possivel alterar um pedido já ativo!');
            }
            else if(oldOrder.Account != newOrder.Account) {
                newOrder.addError('Não é possivel alterar a conta do pedido após sua criação');
            }
        }
    }
}