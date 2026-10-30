public with sharing class TaxService {

    public List<Tax__c> getTaxes(List<OrderItem> orderItems) {
        if(orderItems == null || orderItems.isEmpty()) return new List<Tax__c>();
        Set<Id> productIds = new Set<Id>();
        for(OrderItem item : orderItems) {
            if(item.Product2Id != null) {
                productIds.add(item.Product2Id);
            }
        }
        List<Tax__c> taxes = [SELECT CreatedDate, Distribution_Center__c, Id, Product__c, State__c, Status__c, Tax_on_Cost__c FROM Tax__c WHERE Status__c = 'Approved' AND Product__c IN :productIds ORDER BY CreatedDate DESC];

        return taxes;
    }

    public Tax__c getSpecificTax(OrderItem item, Order orderRecord, List<Tax__c> taxes) {
        if (item == null || item.Product2Id == null || orderRecord == null || taxes == null || taxes.isEmpty()) {
            return null;
        }

        Id stateId;

        if (orderRecord.Account_Address__r != null && orderRecord.Account_Address__r.City__r != null) {
            stateId = orderRecord.Account_Address__r.City__r.State__c;
        }

        Tax__c bestTax;

        for (Tax__c tax : taxes) {
            if (tax.Product__c == item.Product2Id && tax.Distribution_Center__c == orderRecord.Distribution_Center__c && tax.State__c == stateId) {
                if (bestTax == null || (tax.CreatedDate != null && (bestTax.CreatedDate == null || tax.CreatedDate > bestTax.CreatedDate))) {
                    bestTax = tax;
                }
            }
        }
        return bestTax;
    }
}