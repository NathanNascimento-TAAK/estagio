public with sharing class FreightTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
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