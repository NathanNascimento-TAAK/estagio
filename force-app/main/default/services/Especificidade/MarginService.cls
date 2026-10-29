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

        List<Margin__c> candidateMargins = [
            SELECT Account_Group__c, Account__c, City__c, Country__c, CreatedDate, Distribution_Center__c, Id, Product_Hierarchy__c, Product__c, State__c, Status__c, Value__c FROM Margin__c WHERE Status__c = 'Approved' AND (Product__c IN :productIds OR Product_Hierarchy__c IN :productHierarchyIds) ORDER BY CreatedDate DESC
        ];
        return candidateMargins;
    }

    public Margin__c getSpecificMargin(OrderItem item, Product2 product, Order orderRecord, List<Margin__c> margins) {
        if (item == null || product == null || orderRecord == null || margins == null || margins.isEmpty()) {
            return null;
        }

        Id accountGroupId = orderRecord.Account != null ? orderRecord.Account.Account_Group__c : null;

        Id cityId;
        Id stateId;
        Id countryId;

        if (orderRecord.Account_Address__r != null) {
            cityId = orderRecord.Account_Address__r.City__c;

            if (orderRecord.Account_Address__r.City__r != null) {
                stateId = orderRecord.Account_Address__r.City__r.State__c;

                if (orderRecord.Account_Address__r.City__r.State__r != null) {
                    countryId =
                        orderRecord.Account_Address__r.City__r.State__r.Country__c;
                }
            }
        }

        Margin__c bestMargin;
        Integer bestScore = 0;

        for (Margin__c margin : margins) {

            if (margin.Distribution_Center__c !=
                orderRecord.Distribution_Center__c) {
                continue;
            }

            // produto e hierarquia
            Boolean exactProduct = margin.Product__c != null && margin.Product__c == item.Product2Id;

            Boolean exactHierarchy = margin.Product_Hierarchy__c != null && margin.Product_Hierarchy__c == product.Product_Hierarchy__c;

            if (!exactProduct && !exactHierarchy) {
                continue;
            }

            Integer productScore = exactProduct ? 2000 : 1000;

            //cliente e grupo de contas
            Boolean exactAccount = margin.Account__c != null && margin.Account__c == orderRecord.AccountId;

            Boolean exactAccountGroup = margin.Account_Group__c != null && margin.Account_Group__c == accountGroupId;

            if (!exactAccount && !exactAccountGroup) {
                continue;
            }

            Integer accountScore = exactAccount ? 200 : 100;

            //localidade
            Boolean exactCity = margin.City__c != null && margin.City__c == cityId;

            Boolean exactState = margin.State__c != null && margin.State__c == stateId;

            Boolean exactCountry = margin.Country__c != null && margin.Country__c == countryId;

            if (!exactCity && !exactState && !exactCountry) {
                continue;
            }

            Integer locationScore = exactCity ? 30 : exactState ? 20 : 10;

            Integer currentScore = productScore + accountScore + locationScore;

            if (bestMargin == null || currentScore > bestScore || (currentScore == bestScore && margin.CreatedDate > bestMargin.CreatedDate)) {
                bestMargin = margin;
                bestScore = currentScore;
            }
        }
        return bestMargin;
    }
}