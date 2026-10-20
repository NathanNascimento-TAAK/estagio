public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        Set<Id> productIds = new Set<Id>();
        OrderItemService ois = new OrderItemService();
        FreightService fs = new FreightService();
        MarginService ms = new MarginService();
        TaxService ts = new TaxService();
        List<Freight__c> freights = fs.getFreights((List<OrderItem>) Trigger.new);
        List<Margin__c> margins = ms.getMargins((List<OrderItem>) Trigger.new);
        List<Tax__c> taxes = ts.getTaxes((List<OrderItem>) Trigger.new);
        for(OrderItem ord : (List<OrderItem>) Trigger.new) {
            if(ord.Product2Id == null) {
                ord.addError('O produto do item do pedido não pode ser nulo.');
                continue;
            }
            productIds.add(ord.Product2Id);
            ord.Margin_Percentage__c = ms.getSpecificMargin(ord, margins).Value__c;
            ord.Shipping_Cost__c = fs.getSpecificFreight(ord, freights).Value__c;
            ord.Tax_Percentage__c = ts.getSpecificTax(ord, taxes).Tax_on_Cost__c;
            if(!ois.validatePercentages(ord.Margin_Percentage__c, ord.Shipping_Cost__c, ord.Tax_Percentage__c)) {
                ord.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
        Map<Id, Product2> productsById = new Map<Id, Product2>([SELECT Id, Production_Cost__c FROM Product2 WHERE Id IN :productIds]);
        for(OrderItem ord : (List<OrderItem>) Trigger.new) {
            Product2 product = productsById.get(ord.Product2Id);
            ord.Price_without_Margin__c = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c);
            ord.UnitPrice = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c) * (1 + ord.Margin_Percentage__c);
            if(ord.Discount__c == null) {
                ord.Discount__c = 0;
            }
            ord.Final_Price__c = ord.UnitPrice * ord.Quantity * (1 - ord.Discount__c);
            if(ord.Final_Price__c == 0) {
                ord.addError('O preço final do item do pedido não pode ser zero. Contate o time de Pricing.');
            }
        }
    }

    public override void beforeUpdate() {
        Set<Id> productIds = new Set<Id>();
        for(OrderItem ord : (List<OrderItem>) Trigger.new) {
            productIds.add(ord.Product2Id);
        }
        Map<Id, Product2> productsById = new Map<Id, Product2>([SELECT Id, Production_Cost__c FROM Product2 WHERE Id IN :productIds]);
        for(OrderItem ord : (List<OrderItem>) Trigger.new) {
            Product2 product = productsById.get(ord.Product2Id);
            if(product != null && product.Production_Cost__c != null) {
                ord.Price_without_Margin__c = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c);
                ord.UnitPrice = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c) * (1 + ord.Margin_Percentage__c);
                if(ord.Discount__c == null) {
                    ord.Discount__c = 0;
                }
                ord.Final_Price__c =
                    ord.UnitPrice * ord.Quantity * (1 - ord.Discount__c);
                if(ord.Final_Price__c == 0) {
                    ord.addError('O preço final do item do pedido não pode ser zero. Contate o time de Pricing.');
                }
            }
        }
    }
}