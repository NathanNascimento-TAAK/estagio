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

        for (Margin__c margin : margins) {
            if (margin.Distribution_Center__c != orderRecord.Distribution_Center__c) {
                continue;
            }
            Boolean exactProduct = margin.Product__c == item.Product2Id;
            Boolean exactHierarchy = margin.Product_Hierarchy__c == product.Product_Hierarchy__c;

            if (!exactProduct && !exactHierarchy) {
                continue;
            }

            Boolean exactAccount = margin.Account__c == orderRecord.AccountId;
            Boolean exactAccountGroup = margin.Account_Group__c == accountGroupId;

            if (!exactAccount && !exactAccountGroup) {
                continue;
            }

            Boolean exactCity = margin.City__c != null && margin.City__c == cityId;
            Boolean exactState = margin.State__c != null && margin.State__c == stateId;
            Boolean exactCountry = margin.Country__c != null && margin.Country__c == countryId;

            if (!exactCity && !exactState && !exactCountry) {
                continue;
            }

            if (bestMargin == null) {
                bestMargin = margin;
                continue;
            }

            Boolean bestUsesExactProduct = bestMargin.Product__c == item.Product2Id;
            Boolean bestUsesExactAccount = bestMargin.Account__c == orderRecord.AccountId;
            Boolean bestUsesExactCity = bestMargin.City__c != null && bestMargin.City__c == cityId;
            Boolean bestUsesExactState = bestMargin.State__c != null && bestMargin.State__c == stateId;
            Boolean bestUsesExactCountry = bestMargin.Country__c != null && bestMargin.Country__c == countryId;
            Boolean candidateIsMoreSpecific = false;

            if (exactProduct != bestUsesExactProduct) {
                candidateIsMoreSpecific = exactProduct;
            } else if (exactAccount != bestUsesExactAccount) {
                candidateIsMoreSpecific = exactAccount;
            } else if (exactCity != bestUsesExactCity) {
                candidateIsMoreSpecific = exactCity;
            } else if (exactState != bestUsesExactState) {
                candidateIsMoreSpecific = exactState;
            } else if (exactCountry != bestUsesExactCountry) {
                candidateIsMoreSpecific = exactCountry;
            } else if (margin.CreatedDate != null && (bestMargin.CreatedDate == null || margin.CreatedDate > bestMargin.CreatedDate)) {
                candidateIsMoreSpecific = true;
            }

            if (candidateIsMoreSpecific) {
                bestMargin = margin;
            }
        }
        return bestMargin;
    }

}