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
        Product2 productInsert = new Product2(Name = 'Test product', IsActive = true, Product_Hierarchy__c = productHierarchy.Id, Production_Cost__c = 100);
        insert productInsert;
        
        Product2 product = [SELECT Id, Product_Hierarchy__c FROM Product2 WHERE Name = 'Test product' LIMIT 1];

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
        /*Id distributionCenterId = 'a0B1t00000A1B2C';
        Id distributionCenterId2 = 'a0B1t00000A1B2D';
        Id cityId = 'a0C1t00000D3E4F';
        Id stateId = 'a0D1t00000G5H6I';
        Id countryId = 'a0E1t00000J7K8L';*/

        List<Freight__c> freights = new List<Freight__c>{
            buildFreight(product.Id, null, distributionCenter.Id, city.Id, null, null, 10),
            buildFreight(null, productHierarchy.Id, distributionCenter2.Id, city.Id, null, null, 20),
            buildFreight(null, productHierarchy.Id, distributionCenter.Id, city.Id, null, null, 30),
            buildFreight(product.Id, null, distributionCenter.Id, null, state.Id, null, 40),
            buildFreight(null, productHierarchy.Id, distributionCenter.Id, null, state.Id, null, 50),
            buildFreight(product.Id, null, distributionCenter.Id, null, state.Id, null, 60),
            buildFreight(product.Id, null, distributionCenter.Id, null, null, country.Id, 70),
            buildFreight(null, productHierarchy.Id, distributionCenter.Id, null, state.Id, null, 80),
            buildFreight(null, productHierarchy.Id, distributionCenter.Id, city.Id, null, null, 90),
            buildFreight(product.Id, null, distributionCenter.Id, city.Id, null, null, 10)
        };
        insert freights;
    }

    @IsTest
    static void getFreightsEmptyForNullOrEmpty() {
        FreightService service = new FreightService();

        System.assertEquals(0, service.getFreights(null).size());
        System.assertEquals(0, service.getFreights(new List<OrderItem>()).size());

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test product' LIMIT 1];
        System.assertNotEquals(0, service.getFreights(new List<OrderItem>{new OrderItem(Product2Id = product.Id)}).size());
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
        System.assertEquals(null, service.getSpecificFreight(null, null, orderRecord, freights));
    }

    @IsTest
    static void testSpecificity() {
        FreightService service = new FreightService();

        Product2 product = [SELECT Id, Product_Hierarchy__c FROM Product2 WHERE Name = 'Test product' LIMIT 1];
        Product_Hierarchy__c hierarchy = [SELECT Id FROM Product_Hierarchy__c WHERE Name = 'Test hierarchy' LIMIT 1];

        Distribution_Center__c distributionCenter = [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center' LIMIT 1];
        Distribution_Center__c distributionCenter2 = [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center 2' LIMIT 1];
        City__c city = [SELECT Id FROM City__c WHERE Name = 'Test city' LIMIT 1];
        State__c state = [SELECT Id FROM State__c WHERE Name = 'Test state' LIMIT 1];
        Country__c country = [SELECT Id FROM Country__c WHERE Name = 'Test country' LIMIT 1];

        Order orderRecord = buildOrder(distributionCenter.Id, city.Id, state.Id, country.Id);
        Order orderRecord2 = buildOrder(distributionCenter2.Id, city.Id, state.Id, country.Id);
        OrderItem item = new OrderItem(Product2Id = product.Id);

        List<Freight__c> freights = [SELECT Id, Product__c, Product_Hierarchy__c, Distribution_Center__c, City__c, State__c, Country__c, Value__c, CreatedDate FROM Freight__c];

        Freight__c specificFreight = service.getSpecificFreight(item, product, orderRecord, freights);
        Freight__c specificFreight2 = service.getSpecificFreight(item, product, orderRecord2, freights);
        System.assertNotEquals(null, specificFreight);
        System.assertEquals(10, specificFreight.Value__c);
        System.assertNotEquals(null, specificFreight2);
        System.assertEquals(20, specificFreight2.Value__c);
    }

    private static Freight__c buildFreight(Id productId, Id hierarchyId, Id distributionCenterId, Id cityId, Id stateId, Id countryId, Decimal value) {
        return new Freight__c(Product__c = productId, Product_Hierarchy__c = hierarchyId, Distribution_Center__c = distributionCenterId, City__c = cityId, State__c = stateId, Country__c = countryId, Value__c = value, Status__c =  'Approved');
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

    @IsTest
    static void testInsertErrorFreights() {
        Product_Hierarchy__c productHierarchy = [SELECT Id FROM Product_Hierarchy__c WHERE Name = 'Test hierarchy' LIMIT 1];
        Distribution_Center__c distributionCenter = [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center' LIMIT 1];
        Distribution_Center__c distributionCenter2 = [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center 2' LIMIT 1];
        State__c state = [SELECT Id FROM State__c WHERE Name = 'Test state' LIMIT 1];
        List<Freight__c> errorFreights = new List<Freight__c>{
            buildFreight(null, productHierarchy.Id, distributionCenter2.Id, null, null, null, 20),
            buildFreight(null, null, distributionCenter.Id, null, state.Id, null, 30)
        };
        
        Database.SaveResult[] results = Database.insert(errorFreights, false);

        System.assertEquals(false, results[0].isSuccess());
        System.assertEquals(
            'Preencha uma cidade, um estado ou um país. (Apenas um deles pode ser preenchido.)',
            results[0].getErrors()[0].getMessage()
        );
        System.assertEquals(false, results[1].isSuccess());
        System.assertEquals(
            'Preencha um produto ou uma Hierarquia de produto. (Apenas um deles pode ser preenchido.)',
            results[1].getErrors()[0].getMessage()
        );
    }
}
