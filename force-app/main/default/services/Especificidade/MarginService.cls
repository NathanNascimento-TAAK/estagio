public with sharing class MarginService {
    public List<Margin__c> getMargins(List<OrderItem> orderItems) {
        if (orderItems == null || orderItems.isEmpty()) return new List<Margin__c>();
        List<Margin__c> selectedMargins = new List<Margin__c>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> productHierarchyIds = new Set<Id>();
        for (OrderItem item : orderItems) {
            if (item.Product2Id != null) {
                productIds.add(item.Product2Id);
            }
        }
        List<Product2> products = [SELECT Id, Product_Hierarchy__c FROM Product2 WHERE Id IN :productIds];
        for(Product2 product : products) {
            if (product.Product_Hierarchy__c != null) {
                productHierarchyIds.add(product.Product_Hierarchy__c);
            }
        }

        /*for (Product2 product : productsById.values()) {
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
        }*/

        List<Margin__c> candidateMargins = [
            SELECT Account_Group__c, Account__c, City__c, Country__c, CreatedDate, Distribution_Center__c, Id, Product_Hierarchy__c, Product__c, State__c, Status__c, Value__c FROM Margin__c WHERE Status__c = 'Approved' AND (Product__c IN :productIds OR Product_Hierarchy__c IN :productHierarchyIds) ORDER BY CreatedDate DESC
        ];
        if(candidateMargins.isEmpty()) {
            throw new AuraHandledException('No Margin records found for the given OrderItems.');
        }
        return candidateMargins;
    }

    public Margin__c getSpecificMargin(OrderItem ord, List<Margin__c> margins) {
        Order orderRecord = [SELECT Id, AccountId, Account.Account_Group__c, Account_Address__c, Account_Address__r.City__c, Account_Address__r.City__r.State__c, Account_Address__r.City__r.State__r.Country__c FROM Order WHERE Id = :ord.OrderId LIMIT 1];
        if (margins.isEmpty()) {
            throw new AuraHandledException('No Margin records found for the given OrderItem.');
        }
        Margin__c mostSpecificMargin = null;
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
        /*if (mostSpecificMargin == null) {
            throw new IllegalArgumentException(margins[0] + ' Margin records found, but none matched the specific criteria for OrderItem with Id: ');
        }
        return mostSpecificMargin;*/
        return margins[0];
    }

}