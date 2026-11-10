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
        Product2 product = new Product2(Name = 'Test product', IsActive = true, Product_Hierarchy__c = productHierarchy.Id, Production_Cost__c = 100);
        insert product;

        Distribution_Center__c distributionCenter = new Distribution_Center__c(Name = 'Test distribution center');
        insert distributionCenter;
        Distribution_Center__c distributionCenter2 = new Distribution_Center__c(Name = 'Test distribution center 2');
        insert distributionCenter2;
        
        Country__c country = new Country__c(Name = 'Test country');
        insert country;
        State__c state = new State__c(Name = 'Test state', Sigla__c = 'TS', Country__c = country.Id);
        insert state;
        City__c city = new City__c(Name = 'Test city', IBGE_Code__c = 1234567, State__c = state.Id);
        insert city;

        List<Tax__c> taxes = new List<Tax__c>{
            buildTax(product.Id, distributionCenter.Id, state.Id, 10),
            buildTax(product.Id, distributionCenter.Id, state.Id, 15),
            buildTax(product.Id, distributionCenter2.Id, state.Id, 20),
            buildTax(product.Id, distributionCenter2.Id, state.Id, 25)
        };
        insert taxes;
    }

    @IsTest
    static void getTaxesReturnsEmptyForNullOrEmptyItems() {
        TaxService service = new TaxService();

        System.assertEquals(0, service.getTaxes(null).size());
        System.assertEquals(0, service.getTaxes(new List<OrderItem>()).size());

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test product' LIMIT 1];

        System.assertNotEquals(0, service.getTaxes(new List<OrderItem>{new OrderItem(Product2Id = product.Id)}).size());
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

    @IsTest
    static void testSpecificity() {
        TaxService service = new TaxService();

        Product2 product = [SELECT Id, Product_Hierarchy__c FROM Product2 WHERE Name = 'Test product' LIMIT 1];

        Distribution_Center__c distributionCenter = [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center' LIMIT 1];
        Distribution_Center__c distributionCenter2 = [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center 2' LIMIT 1];
        City__c city = [SELECT Id FROM City__c WHERE Name = 'Test city' LIMIT 1];
        State__c state = [SELECT Id FROM State__c WHERE Name = 'Test state' LIMIT 1];
        Country__c country = [SELECT Id FROM Country__c WHERE Name = 'Test country' LIMIT 1];

        List<Tax__c> taxes = new List<Tax__c>([SELECT Id, Product__c, Distribution_Center__c, State__c, Tax_on_Cost__c, CreatedDate FROM Tax__c]);

        Order orderRecord = buildOrder(distributionCenter.Id, city.Id, state.Id, country.Id);

        Tax__c specificTax = service.getSpecificTax(new OrderItem(Product2Id = product.Id), orderRecord, taxes);
        System.assertNotEquals(null, specificTax);
        System.assertEquals(10, specificTax.Tax_on_Cost__c);
    }

    private static Tax__c buildTax(Id productId, Id distributionCenterId, Id stateId, Decimal taxPercentage) {
        return new Tax__c(Product__c = productId, Distribution_Center__c = distributionCenterId, State__c = stateId, Tax_on_Cost__c = taxPercentage, Status__c = 'Approved');
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