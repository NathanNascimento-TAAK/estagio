@IsTest
private class TaxService_Test {
    @TestSetup
    static void createTestData() {
        Account_Group__c accountGroup = new Account_Group__c(Name = 'Test group');
        insert accountGroup;

        insert new List<Account>{
            new Account(Name = 'Token 0', CNPJ__c = '11.222.333/0001-81', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 1', CNPJ__c = '11.222.334/0001-26', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 2', CNPJ__c = '11.222.335/0001-70', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 3', CNPJ__c = '11.222.336/0001-15', Account_Group__c = accountGroup.Id)
        };

        Product_Hierarchy__c productHierarchy = new Product_Hierarchy__c(Name = 'Test hierarchy');
        insert productHierarchy;
        insert new Product2(Name = 'Test product', IsActive = true, Product_Hierarchy__c = productHierarchy.Id, Production_Cost__c = 100);
    }

    @IsTest
    static void getTaxesReturnsEmptyForNullOrEmptyItems() {
        TaxService service = new TaxService();

        System.assertEquals(0, service.getTaxes(null).size());
        System.assertEquals(0, service.getTaxes(new List<OrderItem>()).size());

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test product' LIMIT 1];

        System.assertEquals(0, service.getTaxes(new List<OrderItem>{new OrderItem(Product2Id = product.Id)}).size());
    }

    @IsTest
    static void getSpecificTaxReturnsNullForIncompleteInputs() {
        TaxService service = new TaxService();
        OrderItem item = new OrderItem();
        Order orderRecord = new Order();
        List<Tax__c> taxes = new List<Tax__c>();

        System.assertEquals(null, service.getSpecificTax(null, orderRecord, taxes));
        System.assertEquals(null, service.getSpecificTax(item, orderRecord, taxes));
        System.assertEquals(null, service.getSpecificTax(item, null, taxes));
        System.assertEquals(null, service.getSpecificTax(item, orderRecord, null));
        System.assertEquals(null, service.getSpecificTax(item, orderRecord, taxes));
    }

    private static Tax__c buildTax(Id productId, Id distributionCenterId, Id stateId, Decimal taxPercentage) {
        return new Tax__c(Product__c = productId, Distribution_Center__c = distributionCenterId, State__c = stateId, Tax_on_Cost__c = taxPercentage);
    }

    private static Order buildOrder(Id distributionCenterId, Id cityId, Id stateId, Id countryId) {
        State__c stateRecord = new State__c(Country__c = countryId);
        City__c cityRecord = new City__c(State__c = stateId);
        cityRecord.State__r = stateRecord;

        Account_Address__c address = new Account_Address__c(City__c = cityId);
        address.City__r = cityRecord;

        Order orderRecord = new Order(Distribution_Center__c = distributionCenterId);
        orderRecord.Account_Address__r = address;
        return orderRecord;
    }
}
