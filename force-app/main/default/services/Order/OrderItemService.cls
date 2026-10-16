public with sharing class OrderItemService {
    public Boolean validatePercentages(Decimal marginPercentage, Decimal shippingCost, Decimal taxPercentage) {
        if(marginPercentage <= 0 || shippingCost <= 0 || taxPercentage <= 0) {
            return false;
        }
        else if(marginPercentage == null || shippingCost == null || taxPercentage == null) {
            return false;
        }
        else return true;
    }

    public List<OrderItem> updateOrderItems(List<OrderItem> orderItems) {
        if(orderItems == null || orderItems.isEmpty()) return new List<OrderItem>();
        List<OrderItem> toUpdateOrderItems = new List<OrderItem>();
        Set<Id> productIds = new Set<Id>();
        for(OrderItem ord : orderItems) {
            productIds.add(ord.Product2Id);
        }
        Map<Id, Product2> productsById = new Map<Id, Product2>([SELECT Id, Production_Cost__c FROM Product2 WHERE Id IN :productIds]);
        for(OrderItem ord : orderItems) {
            Product2 product = productsById.get(ord.Product2Id);
            if(product != null && product.Production_Cost__c != null) {
                ord.Discount__c = (ord.TotalPrice - ord.UnitPrice) / ord.TotalPrice;
                ord.Price_without_Margin__c = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c);
                ord.UnitPrice = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c) * (1 + ord.Margin_Percentage__c);
                toUpdateOrderItems.add(ord);
            }
        }
        return toUpdateOrderItems;
    }

}