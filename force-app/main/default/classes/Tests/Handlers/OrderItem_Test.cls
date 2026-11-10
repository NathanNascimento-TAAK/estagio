@IsTest
private class OrderItem_Test {
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

        Country__c country = new Country__c(Name = 'Test country');
        insert country;
        State__c state = new State__c(Name = 'Test state', Sigla__c = 'TS', Country__c = country.Id);
        insert state;
        City__c city = new City__c(Name = 'Test city', IBGE_Code__c = 1234567, State__c = state.Id);
        insert city;

        Account account = [SELECT Id FROM Account WHERE Name = 'Token 0' LIMIT 1];
        insert new Account_Address__c(
            Name = 'Test address',
            Account__c = account.Id,
            Street_Address__c = '123 Test Street',
            CEP__c = '12345678',
            District__c = 'Test district',
            City__c = city.Id
        );

        List<Freight__c> freights = new List<Freight__c>{
            buildFreight(product.Id, distributionCenter.Id, city.Id, null, null, 10),
            buildFreight(product.Id, distributionCenter.Id, null, state.Id, null, 15),
            buildFreight(product.Id, distributionCenter.Id, null, null, country.Id, 20)
        };
        insert freights;

        Margin__c margin = buildMargin(product.Id, distributionCenter.Id, account.Id, city.Id, null, null, 10);
        insert margin;
        Tax__c tax = buildTax(product.Id, distributionCenter.Id, state.Id, 10);
        insert tax;

        Id standardPricebookId = Test.getStandardPricebookId();
        insert new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert new Payment_Term__c(Name = 'Test payment term');

    }

    @IsTest
    static void insertCalculatesPricingFields() {
        OrderItem item = newOrderItem(2);

        Test.startTest();
        insert item;
        Test.stopTest();

        OrderItem insertedItem = [
            SELECT Margin_Percentage__c, Shipping_Cost__c, Tax_Percentage__c,
                Price_without_Margin__c, UnitPrice, Final_Price__c, Discount__c
            FROM OrderItem
            WHERE Id = :item.Id
        ];
        System.assertEquals(10, insertedItem.Margin_Percentage__c);
        System.assertEquals(10, insertedItem.Shipping_Cost__c);
        System.assertEquals(10, insertedItem.Tax_Percentage__c);
        System.assertEquals(121, insertedItem.Price_without_Margin__c);
        System.assertEquals(133.1, insertedItem.UnitPrice);
        System.assertEquals(266.2, insertedItem.Final_Price__c);
        System.assertEquals(0.5, insertedItem.Discount__c);
    }

    @IsTest
    static void insertRejectsOrderWithoutPricingParameters() {
        Distribution_Center__c unmatchedDistributionCenter = new Distribution_Center__c(Name = 'Unmatched distribution center');
        insert unmatchedDistributionCenter;
        Order orderRecord = buildOrder(unmatchedDistributionCenter.Id);
        insert orderRecord;
        PricebookEntry pricebookEntry = [
            SELECT Id, Product2Id
            FROM PricebookEntry
            WHERE Product2.Name = 'Test product'
            LIMIT 1
        ];
        OrderItem item = new OrderItem(
            OrderId = orderRecord.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(item, false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess());
        System.assert(
            result.getErrors()[0].getMessage().contains('Não existem parâmetros de precificação compatíveis com este item.')
        );
    }

    @IsTest
    static void updateRecalculatesPricingFields() {
        OrderItem item = newOrderItem(2);
        insert item;
        OrderItem itemToUpdate = new OrderItem(Id = item.Id, Quantity = 3);

        Test.startTest();
        Database.SaveResult updateResult = Database.update(itemToUpdate, false);
        Test.stopTest();
        System.assertEquals(true, updateResult.isSuccess(), updateResult.getErrors().toString());

        OrderItem updatedItem = [
            SELECT Price_without_Margin__c, UnitPrice, Final_Price__c, Discount__c
            FROM OrderItem
            WHERE Id = :item.Id
        ];
        System.assertEquals(121, updatedItem.Price_without_Margin__c);
        System.assertEquals(133.1, updatedItem.UnitPrice);
        System.assertEquals(399.3, updatedItem.Final_Price__c);
        System.assert(updatedItem.Discount__c > 0.65 && updatedItem.Discount__c < 0.68);
    }

    @IsTest
    static void updateRejectsAccountChangeOnOrder() {
        Order orderRecord = buildOrder(
            [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center' LIMIT 1].Id
        );
        insert orderRecord;
        orderRecord.AccountId = [SELECT Id FROM Account WHERE Name = 'Token 1' LIMIT 1].Id;

        Test.startTest();
        Database.SaveResult result = Database.update(orderRecord, false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess());
        System.assert(
            result.getErrors()[0].getMessage().contains('Não é possivel alterar a conta do pedido após sua criação')
        );
    }

    private static OrderItem newOrderItem(Decimal quantity) {
        Order orderRecord = buildOrder(
            [SELECT Id FROM Distribution_Center__c WHERE Name = 'Test distribution center' LIMIT 1].Id
        );
        insert orderRecord;

        PricebookEntry pricebookEntry = [
            SELECT Id, Product2Id
            FROM PricebookEntry
            WHERE Product2.Name = 'Test product'
            LIMIT 1
        ];
        return new OrderItem(
            OrderId = orderRecord.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = quantity,
            UnitPrice = 100
        );
    }

    private static Order buildOrder(Id distributionCenterId) {
        Account account = [SELECT Id FROM Account WHERE Name = 'Token 0' LIMIT 1];
        Payment_Term__c paymentTerm = [SELECT Id FROM Payment_Term__c WHERE Name = 'Test payment term' LIMIT 1];
        Account_Address__c address = [
            SELECT Id
            FROM Account_Address__c
            WHERE Name = 'Test address'
            LIMIT 1
        ];
        return new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            Distribution_Center__c = distributionCenterId,
            Account_Address__c = address.Id,
            Payment_Term__c = paymentTerm.Id,
            Delivery_Date__c = DateTime.now()
        );
    }

    private static Freight__c buildFreight(Id productId, Id distributionCenterId, Id cityId, Id stateId, Id countryId, Decimal value) {
        return new Freight__c(
            Product__c = productId,
            Distribution_Center__c = distributionCenterId,
            City__c = cityId,
            State__c = stateId,
            Country__c = countryId,
            Value__c = value,
            Status__c = 'Approved'
        );
    }

    private static Margin__c buildMargin(Id productId, Id distributionCenterId, Id accountId, Id cityId, Id stateId, Id countryId, Decimal value) {
        return new Margin__c(
            Product__c = productId,
            Distribution_Center__c = distributionCenterId,
            Account__c = accountId,
            City__c = cityId,
            State__c = stateId,
            Country__c = countryId,
            Value__c = value,
            Status__c = 'Approved'
        );
    }

    private static Tax__c buildTax(Id productId, Id distributionCenterId, Id stateId, Decimal taxOnCost) {
        return new Tax__c(
            Product__c = productId,
            Distribution_Center__c = distributionCenterId,
            State__c = stateId,
            Tax_on_Cost__c = taxOnCost,
            Status__c = 'Approved'
        );
    }
}