public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        OrderItemService ois = new OrderItemService();
        FreightService fs = new FreightService();
        MarginService ms = new MarginService();
        TaxService ts = new TaxService();
        List<Freight__c> freights = fs.getFreights((List<OrderItem>) Trigger.new);
        List<Margin__c> margins = ms.getMargins((List<OrderItem>) Trigger.new);
        List<Tax__c> taxes = ts.getTaxes((List<OrderItem>) Trigger.new);
        for(OrderItem ord : (List<OrderItem>) Trigger.new) {
            ord.Margin_Percentage__c = ms.getSpecificMargin(ord, margins).Value__c;
            ord.Shipping_Cost__c = fs.getSpecificFreight(ord, freights).Value__c;
            ord.Tax_Percentage__c = ts.getSpecificTax(ord, taxes).Tax_on_Cost__c;
            if(!ois.validatePercentages(ord.Margin_Percentage__c, ord.Shipping_Cost__c, ord.Tax_Percentage__c)) {
                ord.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
    }

    public override void afterUpdate() {
        OrderItemService ois = new OrderItemService();
        List<OrderItem> orderItems = ois.updateOrderItems((List<OrderItem>) Trigger.new);
        TriggerHandler.bypass('OrderItemTriggerHandler');
        update orderItems;
        TriggerHandler.clearBypass('OrderItemTriggerHandler');
    }
}