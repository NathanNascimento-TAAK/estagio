public with sharing class MarginTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        for(Margin__c margin : (List<Margin__c>) Trigger.new) {
            if(margin.Product__c == null && margin.Product_Hierarchy__c == null || margin.Product__c != null && margin.Product_Hierarchy__c != null) {
                margin.addError('Preencha um produto ou uma Hierarquia de produto. (Apenas um deles pode ser preenchido.)');
            }
            else if(margin.Account__c == null && margin.Account_Group__c == null || margin.Account__c != null && margin.Account_Group__c != null) {
                margin.addError('Preencha uma conta ou um Grupo de contas. (Apenas um deles pode ser preenchido.)');
            }
            else if(margin.City__c == null && margin.State__c == null && margin.Country__c == null || margin.City__c != null && margin.State__c != null && margin.Country__c != null || margin.City__c != null && margin.State__c != null || margin.City__c != null && margin.Country__c != null || margin.State__c != null && margin.Country__c != null) {
                margin.addError('Preencha uma cidade, um estado ou um país. (Apenas um deles pode ser preenchido.)');
            }
        }
    } 
}