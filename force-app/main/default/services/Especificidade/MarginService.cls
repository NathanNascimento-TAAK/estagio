public with sharing class MarginService {
    public List<Margin__c> getMargins(List<OrderItem> orderItems) {
        if (orderItems == null || orderItems.isEmpty()) return new List<Margin__c>();
        List<Margin__c> selectedMargins = new List<Margin__c>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        for (OrderItem item : orderItems) {
            if (item.Product2Id != null) {
                productIds.add(item.Product2Id);
            }
            if (item.OrderId != null) {
                orderIds.add(item.OrderId);
            }
        }

        if (productIds.isEmpty() || orderIds.isEmpty()) {
            return selectedMargins;
        }

        Map<Id, Product2> productsById = new Map<Id, Product2>([
            SELECT Id, Product_Hierarchy__c
            FROM Product2
            WHERE Id IN :productIds
        ]);
        Map<Id, Order> ordersById = new Map<Id, Order>([
            SELECT Id, AccountId, Account.Account_Group__c,
                Account_Address__c, Account_Address__r.City__c, Account_Address__r.City__r.State__c, Account_Address__r.City__r.State__r.Country__c
            FROM Order
            WHERE Id IN :orderIds
        ]);

        Set<Id> hierarchyIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> accountGroupIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();

        for (Product2 product : productsById.values()) {
            if (product.Product_Hierarchy__c != null) {
                hierarchyIds.add(product.Product_Hierarchy__c);
            }
        }
        for (Order orderRecord : ordersById.values()) {
            if (orderRecord.AccountId != null) {
                accountIds.add(orderRecord.AccountId);
            }
            if (orderRecord.Account != null && orderRecord.Account.Account_Group__c != null) {
                accountGroupIds.add(orderRecord.Account.Account_Group__c);
            }
            if (orderRecord.Account_Address__c != null) {
                if (orderRecord.Account_Address__r.City__c != null) {
                    cityIds.add(orderRecord.Account_Address__r.City__c);
                    stateIds.add(orderRecord.Account_Address__r.City__r.State__c);
                    countryIds.add(orderRecord.Account_Address__r.City__r.State__r.Country__c);
                }
            }
        }

        if (accountIds.isEmpty() && accountGroupIds.isEmpty()) {
            return selectedMargins;
        }
        if (cityIds.isEmpty() && stateIds.isEmpty() && countryIds.isEmpty()) {
            return selectedMargins;
        }

        List<Margin__c> candidateMargins = [
            SELECT Id, Product__c, Product_Hierarchy__c, Account__c, Account_Group__c,
                City__c, State__c, Country__c, CreatedDate
            FROM Margin__c
            WHERE (Product__c IN :productIds OR Product_Hierarchy__c IN :hierarchyIds)
                AND (Account__c IN :accountIds OR Account_Group__c IN :accountGroupIds)
                AND (City__c IN :cityIds OR State__c IN :stateIds OR Country__c IN :countryIds)
            ORDER BY CreatedDate DESC
        ];

        return candidateMargins;
    }

    public Margin__c getSpecificMargin(OrderItem ord, List<Margin__c> margins) {
        Order orderRecord = [SELECT Id, AccountId, Account.Account_Group__c, Account_Address__c, Account_Address__r.City__c, Account_Address__r.City__r.State__c, Account_Address__r.City__r.State__r.Country__c FROM Order WHERE Id = :ord.OrderId LIMIT 1];
        if (margins.isEmpty()) return null;
        for (Margin__c margin : margins) {
            if (margin.Product__c == null && margin.Product_Hierarchy__c == ord.Product2.Product_Hierarchy__c) {
                //if do mais especifico (hierarqia)
                if(margin.Account__c == orderRecord.AccountId && margin.City__c == orderRecord.Account_Address__r.City__c) return margin;
            }

            else if (margin.Product__c == ord.Product2Id) {
                // if do mais especifico (produto)
                if(margin.Account_Group__c == orderRecord.Account.Account_Group__c && margin.State__c == orderRecord.Account_Address__r.City__r.State__c) return margin;
                else if(margin.Account_Group__c == orderRecord.Account.Account_Group__c && margin.Country__c == orderRecord.Account_Address__r.City__r.State__r.Country__c) return margin;
            }
        }
        return null;
    }
}