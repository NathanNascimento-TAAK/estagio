public with sharing class OrderTriggerHandler extends TriggerHandler {
    public override void beforeUpdate() {
        for(Integer i = 0; i < Trigger.new.size(); i++) {
            Order oldOrder = (Order) Trigger.old[i];
            Order newOrder = (Order) Trigger.new[i];
            if(oldOrder.Status == 'Activated') {
                newOrder.addError('Não é possivel alterar um pedido já ativo!');
            }
            else if(oldOrder.Account != newOrder.Account) {
                newOrder.addError('Não é possivel alterar a conta do pedido após sua criação');
            }
        }
    }
}