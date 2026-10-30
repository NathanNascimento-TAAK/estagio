public with sharing class FreightTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        Set<Id> productIds = new Set<Id>();
        Set<Id> productHierarchyIds = new Set<Id>();
        Set<Id> dcIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
        for(Freight__c freight : (List<Freight__c>) Trigger.new) {
            productIds.add(freight.Product__c);
            productHierarchyIds.add(freight.Product_Hierarchy__c);
            dcIds.add(freight.Distribution_Center__c);
            stateIds.add(freight.State__c);
            cityIds.add(freight.City__c);
            countryIds.add(freight.Country__c);
        }
        List<Freight__c> existingFreights = [SELECT Id, Product__c, Product_Hierarchy__c, Distribution_Center__c, State__c, City__c, Country__c FROM Freight__c WHERE (Product__c IN :productIds OR Product_Hierarchy__c IN :productHierarchyIds) AND Distribution_Center__c IN :dcIds AND (State__c IN :stateIds OR City__c IN :cityIds OR Country__c IN :countryIds)];
        for(Freight__c freight : (List<Freight__c>) Trigger.new) {
            if(freight.Product__c == null && freight.Product_Hierarchy__c == null || freight.Product__c != null && freight.Product_Hierarchy__c != null) {
                freight.addError('Preencha um produto ou uma Hierarquia de produto. (Apenas um deles pode ser preenchido.)');
            }
            else if(freight.City__c == null && freight.State__c == null && freight.Country__c == null || freight.City__c != null && freight.State__c != null && freight.Country__c != null || freight.City__c != null && freight.State__c != null || freight.City__c != null && freight.Country__c != null || freight.State__c != null && freight.Country__c != null) {
                freight.addError('Preencha uma cidade, um estado ou um país. (Apenas um deles pode ser preenchido.)');
            }
        }
    }
}