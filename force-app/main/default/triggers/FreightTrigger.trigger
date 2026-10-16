trigger FreightTrigger on Freight__c (before insert) {
    new FreightTriggerHandler().run();
}