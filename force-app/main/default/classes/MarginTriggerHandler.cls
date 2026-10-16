public with sharing class MarginTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        for(OrderItem ord : (List<OrderItem>) Trigger.new) {
            if(ord.Margin_Percentage__c == null || ord.Margin_Percentage__c <= 0) {
                ord.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
    } 
}