public with sharing class TaxService {

    public List<Tax__c> getTaxes(List<OrderItem> orderItems) {
        if(orderItems == null || orderItems.isEmpty()) return new List<Tax__c>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        for(OrderItem item : orderItems) {
            if(item.Product2Id != null) {
                productIds.add(item.Product2Id);
            }
            if(item.OrderId != null) {
                orderIds.add(item.OrderId);
            }
        }
        Set<Id> dcIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        List<Order> orders = [SELECT Id, Distribution_Center__c, Account_Address__c, Account_Address__r.City__c, Account_Address__r.City__r.State__c FROM Order WHERE Id IN :orderIds];
        for(Order orderRecord : orders) {
            if(orderRecord.Distribution_Center__c != null) {
                dcIds.add(orderRecord.Distribution_Center__c);
            }
            if(orderRecord.Account_Address__c != null) {
                if(orderRecord.Account_Address__r.City__r.State__c != null) {
                    stateIds.add(orderRecord.Account_Address__r.City__r.State__c);
                }
            }
        }
        if(dcIds.isEmpty() || stateIds.isEmpty() || productIds.isEmpty()) {
            return new List<Tax__c>();
        }
        List<Tax__c> taxes = [SELECT Id, Tax_on_Cost__c, Product__c, Distribution_Center__c, State__c, Status__c, CreatedDate FROM Tax__c WHERE Status__c = 'Approved' AND Product__c IN :productIds AND Distribution_Center__c IN :dcIds AND State__c IN :stateIds ORDER BY CreatedDate DESC];

        return taxes;
    }

    public Tax__c getSpecificTax(OrderItem ord, List<Tax__c> taxes) {
        Order orderRecord = [SELECT Id, AccountId, Account_Address__c, Account_Address__r.City__c, Account_Address__r.City__r.State__c, Account_Address__r.City__r.State__r.Country__c, Distribution_Center__c FROM Order WHERE Id = :ord.OrderId LIMIT 1];
        if(taxes.isEmpty()) return null;
        for(Tax__c tax : taxes) {
            if(tax.Product__c == ord.Product2Id && tax.Distribution_Center__c == orderRecord.Distribution_Center__c && tax.State__c == orderRecord.Account_Address__r.City__r.State__c) {
                return tax;
            }
        }
        return null;
    }
}