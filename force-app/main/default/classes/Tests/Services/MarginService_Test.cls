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

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test product' LIMIT 1];
        List<Account> accounts = [
            SELECT Id, Account_Group__c
            FROM Account
            WHERE Name IN ('Token 0', 'Token 1')
            ORDER BY Name
        ];
        Account account = accounts[0];
        Account account2 = accounts[1];

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

        insert new List<Margin__c>{
            buildMargin(product.Id, null, distributionCenter.Id, account.Id, null, city.Id, null, null, 10),
            buildMargin(product.Id, null, distributionCenter2.Id, account2.Id, null, city.Id, null, null, 60)
        };
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

    @IsTest
    static void testSpecificity() {
        MarginService service = new MarginService();

        Product2 product = [SELECT Id, Product_Hierarchy__c FROM Product2 WHERE Name = 'Test product' LIMIT 1];
        Account account = [SELECT Id, Account_Group__c FROM Account WHERE Name = 'Token 0' LIMIT 1];
        Account account2 = [SELECT Id, Account_Group__c FROM Account WHERE Name = 'Token 1' LIMIT 1];
        Distribution_Center__c distributionCenter = [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center' LIMIT 1];
        Distribution_Center__c distributionCenter2 = [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center 2' LIMIT 1];
        City__c city = [SELECT Id FROM City__c WHERE Name = 'Test city' LIMIT 1];
        State__c state = [SELECT Id FROM State__c WHERE Name = 'Test state' LIMIT 1];
        Country__c country = [SELECT Id FROM Country__c WHERE Name = 'Test country' LIMIT 1];

        Order orderRecord = buildOrder(distributionCenter.Id, account, city.Id, state.Id, country.Id);
        Order orderRecord2 = buildOrder(distributionCenter2.Id, account2, city.Id, state.Id, country.Id);
        OrderItem item = new OrderItem(Product2Id = product.Id);

        List<Margin__c> margins = service.getMargins(new List<OrderItem>{item});
        margins.add(buildMargin(product.Id, null, distributionCenter.Id, null, account.Account_Group__c, null, state.Id, null, 30));
        margins.add(buildMargin(product.Id, null, distributionCenter.Id, account.Id, null, null, null, country.Id, 20));
        margins.add(buildMargin(null, product.Product_Hierarchy__c, distributionCenter.Id, account.Id, null, city.Id, null, null, 40));
        margins.add(buildMargin(null, product.Product_Hierarchy__c, distributionCenter.Id, null, account.Account_Group__c, null, null, country.Id, 50));
        margins.add(buildMargin(product.Id, null, distributionCenter2.Id, null, account2.Account_Group__c, null, state.Id, null, 70));
        margins.add(buildMargin(null, product.Product_Hierarchy__c, distributionCenter2.Id, account2.Id, null, null, state.Id, null, 80));

        Margin__c specificMargin = service.getSpecificMargin(item, product, orderRecord, margins);
        Margin__c specificMargin2 = service.getSpecificMargin(item, product, orderRecord2, margins);
        System.assertNotEquals(null, specificMargin);
        System.assertEquals(10, specificMargin.Value__c);
        System.assertNotEquals(null, specificMargin2);
        System.assertEquals(60, specificMargin2.Value__c);
    }

    @IsTest
    static void triggerRejectsInvalidMarginSpecificity() {
        Product2 product = [SELECT Id, Product_Hierarchy__c FROM Product2 WHERE Name = 'Test product' LIMIT 1];
        Account account = [SELECT Id, Account_Group__c FROM Account WHERE Name = 'Token 0' LIMIT 1];
        Distribution_Center__c distributionCenter = [
            SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center' LIMIT 1
        ];
        City__c city = [SELECT Id FROM City__c WHERE Name = 'Test city' LIMIT 1];
        State__c state = [SELECT Id FROM State__c WHERE Name = 'Test state' LIMIT 1];

        List<Margin__c> invalidMargins = new List<Margin__c>{
            buildMargin(null, null, distributionCenter.Id, account.Id, null, city.Id, null, null, 10),
            buildMargin(product.Id, product.Product_Hierarchy__c, distributionCenter.Id, account.Id, null, city.Id, null, null, 10),
            buildMargin(product.Id, null, distributionCenter.Id, null, null, city.Id, null, null, 10),
            buildMargin(product.Id, null, distributionCenter.Id, account.Id, account.Account_Group__c, city.Id, null, null, 10),
            buildMargin(product.Id, null, distributionCenter.Id, account.Id, null, null, null, null, 10),
            buildMargin(product.Id, null, distributionCenter.Id, account.Id, null, city.Id, state.Id, null, 10)
        };

        Test.startTest();
        Database.SaveResult[] results = Database.insert(invalidMargins, false);
        Test.stopTest();

        System.assertEquals(6, results.size());
        for (Database.SaveResult result : results) {
            System.assertEquals(false, result.isSuccess());
        }
        System.assert(
            results[0].getErrors()[0].getMessage().contains('Preencha um produto ou uma Hierarquia de produto.')
        );
        System.assert(
            results[1].getErrors()[0].getMessage().contains('Preencha um produto ou uma Hierarquia de produto.')
        );
        System.assert(
            results[2].getErrors()[0].getMessage().contains('Preencha uma conta ou um Grupo de contas.')
        );
        System.assert(
            results[3].getErrors()[0].getMessage().contains('Preencha uma conta ou um Grupo de contas.')
        );
        System.assert(
            results[4].getErrors()[0].getMessage().contains('Preencha uma cidade, um estado ou um país.')
        );
        System.assert(
            results[5].getErrors()[0].getMessage().contains('Preencha uma cidade, um estado ou um país.')
        );
    }

    private static Margin__c buildMargin(Id productId, Id hierarchyId, Id distributionCenterId, Id accountId, Id accountGroupId, Id cityId, Id stateId, Id countryId, Decimal value) {
        return new Margin__c(Product__c = productId, Product_Hierarchy__c = hierarchyId, Distribution_Center__c = distributionCenterId, Account__c = accountId, Account_Group__c = accountGroupId, City__c = cityId, State__c = stateId, Country__c = countryId, Value__c = value, Status__c = 'Approved');
    }

    private static Order buildOrder(Id distributionCenterId, Account account, Id cityId, Id stateId, Id countryId) {
        State__c stateRecord = new State__c(Country__c = countryId);
        City__c cityRecord = new City__c(State__c = stateId);
        cityRecord.State__r = stateRecord;

        Account_Address__c address = new Account_Address__c(City__c = cityId);
        address.City__r = cityRecord;

        Order orderRecord = new Order(Distribution_Center__c = distributionCenterId, AccountId = account.Id);
        orderRecord.Account = account;
        orderRecord.Account_Address__r = address;
        return orderRecord;
    }
}
