public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        Set<Id> productIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        OrderItemService ois = new OrderItemService();
        FreightService fs = new FreightService();
        MarginService ms = new MarginService();
        TaxService ts = new TaxService();
        List<Freight__c> freights = fs.getFreights((List<OrderItem>) Trigger.new);
        List<Margin__c> margins = ms.getMargins((List<OrderItem>) Trigger.new);
        List<Tax__c> taxes = ts.getTaxes((List<OrderItem>) Trigger.new);

        for(OrderItem ord : (List<OrderItem>) Trigger.new) {
            if (ord.Product2Id != null) {
                productIds.add(ord.Product2Id);
            }

            if (ord.OrderId != null) {
                orderIds.add(ord.OrderId);
            }
        }

        Map<Id, Product2> productsById = new Map<Id, Product2>([
            SELECT Id, Product_Hierarchy__c, Production_Cost__c
            FROM Product2
            WHERE Id IN :productIds
        ]);

        Map<Id, Order> ordersById = new Map<Id, Order>([
            SELECT Id, AccountId, Account.Account_Group__c,
                Account_Address__c,
                Account_Address__r.City__c,
                Account_Address__r.City__r.State__c,
                Account_Address__r.City__r.State__r.Country__c,
                Distribution_Center__c
            FROM Order
            WHERE Id IN :orderIds
        ]);

        for (OrderItem ord : (List<OrderItem>) Trigger.new) {
            Product2 product = productsById.get(ord.Product2Id);
            Order orderRecord = ordersById.get(ord.OrderId);

            if (product == null || orderRecord == null) {
                ord.addError('Não foi possível localizar o produto ou o pedido.');
                continue;
            }

            Margin__c margin = ms.getSpecificMargin(ord, product, orderRecord, margins);

            Freight__c freight = fs.getSpecificFreight(ord, product, orderRecord, freights);

            Tax__c tax = ts.getSpecificTax(ord, orderRecord, taxes);

            if (margin == null || freight == null || tax == null) {
                ord.addError('Não existem parâmetros de precificação compatíveis com este item.');
                continue;
            }

            ord.Margin_Percentage__c = margin.Value__c;
            ord.Shipping_Cost__c = freight.Value__c;
            ord.Tax_Percentage__c = tax.Tax_on_Cost__c;

            if(!ois.validatePercentages(ord.Margin_Percentage__c, ord.Shipping_Cost__c, ord.Tax_Percentage__c)) {
                ord.addError('Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }

        for(OrderItem ord : (List<OrderItem>) Trigger.new) {
            Product2 product = productsById.get(ord.Product2Id);
            if (product == null || ord.Margin_Percentage__c == null || ord.Shipping_Cost__c == null || ord.Tax_Percentage__c == null || ord.Quantity == null) {
                continue;
            }
            if (product.Production_Cost__c == null) {
                ord.addError('Não foi possível localizar o custo de produção do produto.');
                continue;
            }
            ord.Price_without_Margin__c = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c / 100);
            ord.UnitPrice = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c / 100) * (1 + ord.Margin_Percentage__c / 100);
            ord.Final_Price__c = ord.UnitPrice * ord.Quantity;
            if(ord.Final_Price__c == 0) {
                ord.addError('O preço final do item do pedido não pode ser zero. Contate o time de Pricing.');
                continue;
            }
            ord.Discount__c = (ord.Final_Price__c - ord.UnitPrice) / ord.Final_Price__c;
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
                ord.Price_without_Margin__c = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c / 100);
                ord.UnitPrice = (product.Production_Cost__c + ord.Shipping_Cost__c) * (1 + ord.Tax_Percentage__c / 100) * (1 + ord.Margin_Percentage__c / 100);
                ord.Final_Price__c = ord.UnitPrice * ord.Quantity;
                if(ord.Final_Price__c == 0) {
                    ord.addError('O preço final do item do pedido não pode ser zero. Contate o time de Pricing.');
                }
                ord.Discount__c = (ord.Final_Price__c - ord.UnitPrice) / ord.Final_Price__c;
            }
        }
    }
}