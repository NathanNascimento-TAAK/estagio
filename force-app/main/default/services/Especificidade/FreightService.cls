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

    public Freight__c getSpecificFreight(OrderItem item, Product2 product, Order orderRecord, List<Freight__c> freights) {
        if (item == null || product == null || orderRecord == null || freights == null || freights.isEmpty()) {
            return null;
        }

        // Identifica a localidade do pedido.
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
        Integer bestScore = 0;

        for (Freight__c freight : freights) {

            // 1. O centro de distribuição precisa corresponder.
            if (freight.Distribution_Center__c !=
                orderRecord.Distribution_Center__c) {
                continue;
            }

            // 2. Verifica se o frete atende ao produto.
            Boolean exactProduct =
                freight.Product__c != null &&
                freight.Product__c == item.Product2Id;

            Boolean exactHierarchy =
                freight.Product_Hierarchy__c != null &&
                freight.Product_Hierarchy__c == product.Product_Hierarchy__c;

            if (!exactProduct && !exactHierarchy) {
                continue;
            }

            Integer productScore = exactProduct ? 2000 : 1000;

            // 3. Verifica se o frete atende à localidade.
            Boolean exactCity =
                freight.City__c != null && freight.City__c == cityId;

            Boolean exactState =
                freight.State__c != null && freight.State__c == stateId;

            Boolean exactCountry =
                freight.Country__c != null && freight.Country__c == countryId;

            if (!exactCity && !exactState && !exactCountry) {
                continue;
            }

            Integer locationScore = exactCity ? 30 : exactState ? 20 : 10;

            // 4. Calcula a especificidade total.
            Integer currentScore = productScore + locationScore;

            // 5. Seleciona o frete com a maior pontuação.
            if (bestFreight == null || currentScore > bestScore || (currentScore == bestScore && freight.CreatedDate > bestFreight.CreatedDate)) {
                bestFreight = freight;
                bestScore = currentScore;
            }
        }

        return bestFreight;
    }
}