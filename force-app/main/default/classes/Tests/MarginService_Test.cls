@IsTest
private class MarginService_Test {
    @TestSetup
    static void createTestData() {
        Account_Group__c accountGroup = new Account_Group__c(Name = 'Test group');
        insert accountGroup;

        insert new List<Account>{
            new Account(Name = 'Token 0', CNPJ__c = '11.222.333/0001-81', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 1', CNPJ__c = '11.222.334/0001-26', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 2', CNPJ__c = '11.222.335/0001-70', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 3', CNPJ__c = '11.222.336/0001-15', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 4', CNPJ__c = '11.222.337/0001-60', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 5', CNPJ__c = '11.222.338/0001-04', Account_Group__c = accountGroup.Id)
        };

        Product_Hierarchy__c productHierarchy = new Product_Hierarchy__c(Name = 'Test hierarchy');
        insert productHierarchy;
        insert new Product2(Name = 'Test product', IsActive = true, Product_Hierarchy__c = productHierarchy.Id, Production_Cost__c = 100);
    }

    @IsTest
    static void getMarginsReturnsEmptyForNullOrEmptyItems() {
        MarginService service = new MarginService();

        System.assertEquals(0, service.getMargins(null).size());
        System.assertEquals(0, service.getMargins(new List<OrderItem>()).size());
    }

    @IsTest
    static void getSpecificMarginReturnsNullForIncompleteInputs() {
        MarginService service = new MarginService();
        OrderItem item = new OrderItem();
        Product2 product = new Product2();
        Order orderRecord = new Order();
        List<Margin__c> margins = new List<Margin__c>();

        System.assertEquals(null, service.getSpecificMargin(null, product, orderRecord, margins));
        System.assertEquals(null, service.getSpecificMargin(item, null, orderRecord, margins));
        System.assertEquals(null, service.getSpecificMargin(item, product, null, margins));
        System.assertEquals(null, service.getSpecificMargin(item, product, orderRecord, null));
        System.assertEquals(null, service.getSpecificMargin(item, product, orderRecord, margins));
    }

    private static Margin__c buildMargin(Id productId, Id hierarchyId, Id distributionCenterId, Id accountId, Id accountGroupId, Id cityId, Id stateId, Id countryId, Decimal value) {
        return new Margin__c(Product__c = productId, Product_Hierarchy__c = hierarchyId, Distribution_Center__c = distributionCenterId, Account__c = accountId, Account_Group__c = accountGroupId, City__c = cityId, State__c = stateId, Country__c = countryId, Value__c = value);
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
