@IsTest
private class FreightService_Test {
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
            new Account(Name = 'Token 5', CNPJ__c = '11.222.338/0001-04', Account_Group__c = accountGroup.Id),
            new Account(Name = 'Token 6', CNPJ__c = '11.222.339/0001-59', Account_Group__c = accountGroup.Id)
        };

        Product_Hierarchy__c productHierarchy = new Product_Hierarchy__c(Name = 'Test hierarchy');
        insert productHierarchy;
        insert new Product2(Name = 'Test product', IsActive = true, Product_Hierarchy__c = productHierarchy.Id, Production_Cost__c = 100);
    }

    @IsTest
    static void getFreightsEmptyForNullOrEmpty() {
        FreightService service = new FreightService();

        System.assertEquals(0, service.getFreights(null).size());
        System.assertEquals(0, service.getFreights(new List<OrderItem>()).size());

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test product' LIMIT 1];
        System.assertEquals(0, service.getFreights(new List<OrderItem>{new OrderItem(Product2Id = product.Id)}).size());
    }

    @IsTest
    static void getSpecificFreightNullForIncompleteInputs() {
        FreightService service = new FreightService();
        OrderItem item = new OrderItem();
        Product2 product = new Product2();
        Order orderRecord = new Order();
        List<Freight__c> freights = new List<Freight__c>();

        System.assertEquals(null, service.getSpecificFreight(null, product, orderRecord, freights));
        System.assertEquals(null, service.getSpecificFreight(item, null, orderRecord, freights));
        System.assertEquals(null, service.getSpecificFreight(item, product, null, freights));
        System.assertEquals(null, service.getSpecificFreight(item, product, orderRecord, null));
        System.assertEquals(null, service.getSpecificFreight(item, product, orderRecord, freights));
    }

    private static Freight__c buildFreight(Id productId, Id hierarchyId, Id distributionCenterId, Id cityId, Id stateId, Id countryId, Decimal value) {
        return new Freight__c(Product__c = productId, Product_Hierarchy__c = hierarchyId, Distribution_Center__c = distributionCenterId, City__c = cityId, State__c = stateId, Country__c = countryId, Value__c = value);
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
