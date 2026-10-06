public with sharing class ProductTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        Id standartBookId = Test.getStandardPricebookId();

        List<CurrencyType> currencys = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true];

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        for (Product2 product : (List<Product2>) Trigger.new) {
            
            if(product == null) {
                continue;
            }
            for (CurrencyType curr : currencys) {
                PricebookEntry entry = new PricebookEntry();

                entry.Pricebook2Id = standartBookId;
                entry.Product2Id = product.Id;
                entry.UnitPrice = 0;
                entry.CurrencyIsoCode = curr.IsoCode;
                entry.IsActive = true;

                pricebookEntries.add(entry);
            }
        }

        if (!pricebookEntries.isEmpty()) {
            insert pricebookEntries;
        }
    }
}