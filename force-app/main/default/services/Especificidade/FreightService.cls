public with sharing class FreightService {

    public List<Freight__c> getFreights(List<OrderItem> orderItems) {
        if(orderItems == null || orderItems.isEmpty()) return new List<Freight__c>();

        Set<Id> orderIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        for(OrderItem item : orderItems) {
            if(item.OrderId != null) {
                orderIds.add(item.OrderId);
            }
            if(item.Product2Id != null) {
                productIds.add(item.Product2Id);
            }
        }
        Set<Id> dcIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();

        List<Order> orders = [SELECT Id, AccountId, Account_Address__c, Account_Address__r.City__c, Account_Address__r.City__r.State__c, Account_Address__r.City__r.State__r.Country__c, Distribution_Center__c FROM Order WHERE Id IN :orderIds];

        for(Order orderRecord : orders) {
            if(orderRecord.Distribution_Center__c != null) {
                dcIds.add(orderRecord.Distribution_Center__c);
            }
            if(orderRecord.AccountId != null && orderRecord.Account_Address__c != null) {
                if(orderRecord.Account_Address__r.City__c != null) {
                    cityIds.add(orderRecord.Account_Address__r.City__c);
                }
                if(orderRecord.Account_Address__r.City__r.State__c != null) {
                    stateIds.add(orderRecord.Account_Address__r.City__r.State__c);
                }
                if(orderRecord.Account_Address__r.City__r.State__r.Country__c != null) {
                    countryIds.add(orderRecord.Account_Address__r.City__r.State__r.Country__c);
                }
            }
        }

        List<Freight__c> selectedFreights = [SELECT Id, Product__c, Product_Hierarchy__c, Status__c, Value__c, City__c, State__c, Country__c, CreatedDate FROM Freight__c WHERE Status__c = 'Approved' AND Distribution_Center__c IN :dcIds AND Product__c IN :productIds AND (City__c IN :cityIds OR State__c IN :stateIds OR Country__c IN :countryIds) ORDER BY CreatedDate DESC];

        return selectedFreights;
    }

    public Freight__c getSpecificFreight(OrderItem ord,List<Freight__c> freights) {
        Order orderRecord = [SELECT Id, AccountId, Account_Address__c, Account_Address__r.City__c, Account_Address__r.City__r.State__c, Account_Address__r.City__r.State__r.Country__c, Distribution_Center__c FROM Order WHERE Id = :ord.OrderId LIMIT 1];
        if(freights.isEmpty()) return null;
        for(Freight__c freight : freights) {
            if(freight.Product__c == null && freight.Product_Hierarchy__c == ord.Product2.Product_Hierarchy__c) {
                if(freight.City__c == orderRecord.Account_Address__r.City__c) return freight;
                else if(freight.State__c == orderRecord.Account_Address__r.City__r.State__c) return freight;
                else if(freight.Country__c == orderRecord.Account_Address__r.City__r.State__r.Country__c) return freight;
            }
            else if(freight.Product__c == ord.Product2Id) {
                if(freight.City__c == orderRecord.Account_Address__r.City__c) return freight;
                else if(freight.State__c == orderRecord.Account_Address__r.City__r.State__c) return freight;
                else if(freight.Country__c == orderRecord.Account_Address__r.City__r.State__r.Country__c) return freight;
            }
            else continue;
        }

        return freights[0];
    }

    public void validateExistingFreights(List<Freight__c> newFreights, List<Freight__c> existingFreights) {
        for(Freight__c newFreight : newFreights) {
            Boolean hasProduct = newFreight.Product__c != null;
            Boolean hasHierarchy = newFreight.Product_Hierarchy__c != null;
            Boolean hasCity = newFreight.City__c != null;
            Boolean hasState = newFreight.State__c != null;
            Boolean hasCountry = newFreight.Country__c != null;
            Boolean hasSingleProduct = hasProduct != hasHierarchy;
            Boolean hasSingleLocation =
                (hasCity && !hasState && !hasCountry)
                || (!hasCity && hasState && !hasCountry)
                || (!hasCity && !hasState && hasCountry);

            if(!hasSingleProduct || !hasSingleLocation) {
                continue;
            }

            for(Freight__c existingFreight : existingFreights) {
                if(newFreight.Product__c != null && newFreight.Product__c == existingFreight.Product__c && newFreight.Distribution_Center__c == existingFreight.Distribution_Center__c && newFreight.State__c == existingFreight.State__c && newFreight.City__c == existingFreight.City__c && newFreight.Country__c == existingFreight.Country__c) {
                    newFreight.addError('Já existe um registro de frete para este produto/hierarquia e localidade.');
                }
                else if(newFreight.Product_Hierarchy__c != null && newFreight.Product_Hierarchy__c == existingFreight.Product_Hierarchy__c && newFreight.Distribution_Center__c == existingFreight.Distribution_Center__c && newFreight.State__c == existingFreight.State__c && newFreight.City__c == existingFreight.City__c && newFreight.Country__c == existingFreight.Country__c) {
                    newFreight.addError('Já existe um registro de frete para este produto/hierarquia e localidade.');
                }
            }
        }

    }
}