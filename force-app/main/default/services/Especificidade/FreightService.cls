public with sharing class FreightService {

    public List<Freight__c> getFreights(List<OrderItem> orderItems) {
        if(orderItems == null || orderItems.isEmpty()) return new List<Freight__c>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> productHierarchyIds = new Set<Id>();
        for(OrderItem item : orderItems) {
            productIds.add(item.Product2Id);
        }

        List<Product2> products = [SELECT Id, Product_Hierarchy__c FROM Product2 WHERE Id IN :productIds];
        for(Product2 product : products) {
            productHierarchyIds.add(product.Product_Hierarchy__c);
        }
        List<Freight__c> selectedFreights = [SELECT City__c, Country__c, CreatedDate, Distribution_Center__c, Id, LastModifiedById, Product_Hierarchy__c, Product__c, State__c, Status__c, Value__c FROM Freight__c WHERE Product__c IN :productIds OR Product_Hierarchy__c IN :productHierarchyIds ORDER BY CreatedDate DESC ];

        return selectedFreights;
    }

    public Freight__c getSpecificFreight(OrderItem item, Product2 product, Order orderRecord, List<Freight__c> freights){
        if (item == null || product == null || orderRecord == null || freights == null || freights.isEmpty()) {
            return null;
        }

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

        Freight__c bestFreight;

        for (Freight__c freight : freights) {
            if (freight.Distribution_Center__c != orderRecord.Distribution_Center__c) {
                continue;
            }

            Boolean exactProduct = freight.Product__c == item.Product2Id;
            Boolean exactHierarchy = freight.Product_Hierarchy__c == product.Product_Hierarchy__c;

            if (!exactProduct && !exactHierarchy) {
                continue;
            }

            Boolean exactCity = freight.City__c != null && freight.City__c == cityId;
            Boolean exactState = freight.State__c != null && freight.State__c == stateId;
            Boolean exactCountry = freight.Country__c != null && freight.Country__c == countryId;

            if (!exactCity && !exactState && !exactCountry) {
                continue;
            }

            if (bestFreight == null) {
                bestFreight = freight;
                continue;
            }

            Boolean bestUsesExactProduct = bestFreight.Product__c == item.Product2Id;
            Boolean bestUsesExactHierarchy = bestFreight.Product_Hierarchy__c == product.Product_Hierarchy__c;
            Boolean bestUsesExactCity = bestFreight.City__c != null && bestFreight.City__c == cityId;
            Boolean bestUsesExactState = bestFreight.State__c != null && bestFreight.State__c == stateId;
            Boolean bestUsesExactCountry = bestFreight.Country__c != null && bestFreight.Country__c == countryId;
            Boolean candidateIsMoreSpecific = false;

            if (exactProduct != bestUsesExactProduct) {
                candidateIsMoreSpecific = exactProduct;
            } else if (exactCity != bestUsesExactCity) {
                candidateIsMoreSpecific = exactCity;
            } else if (exactState != bestUsesExactState) {
                candidateIsMoreSpecific = exactState;
            } else if (exactCountry != bestUsesExactCountry) {
                candidateIsMoreSpecific = exactCountry;
            } else if (freight.CreatedDate != null && (bestFreight.CreatedDate == null || freight.CreatedDate > bestFreight.CreatedDate)) {
                candidateIsMoreSpecific = true;
            }

            if (candidateIsMoreSpecific) {
                bestFreight = freight;
            }
        }

        return bestFreight;
    }

    public void validateExistingFreights(List<Freight__c> newFreights, List<Freight__c> existingFreights) {
        for(Freight__c newFreight : newFreights) {
            Boolean hasProduct = newFreight.Product__c != null;
            Boolean hasHierarchy = newFreight.Product_Hierarchy__c != null;
            Boolean hasCity = newFreight.City__c != null;
            Boolean hasState = newFreight.State__c != null;
            Boolean hasCountry = newFreight.Country__c != null;
            Boolean hasSingleProduct = hasProduct != hasHierarchy;
            Boolean hasSingleLocation = (hasCity && !hasState && !hasCountry) || (!hasCity && hasState && !hasCountry) || (!hasCity && !hasState && hasCountry);

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