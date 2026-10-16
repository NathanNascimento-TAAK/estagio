trigger MarginTrigger on Margin__c (before insert) {
    new MarginTriggerHandler().run();
}