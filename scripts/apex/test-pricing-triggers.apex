// Run setup-pricing-trigger-test-data.apex first to create the required records.
// Run with: sf apex run --target-org <alias> --file scripts/apex/test-pricing-triggers.apex
// All records created or changed by this script are rolled back at the end.
Savepoint testSavepoint = Database.setSavepoint();
Integer failures = 0;
Integer executed = 0;
Id validFreightId;
Id validMarginId;

List<Order> orderFixtures = [
    SELECT Id, AccountId, Account.Account_Group__c, Account_Address__c,
        Account_Address__r.City__c, Account_Address__r.City__r.State__c,
        Account_Address__r.City__r.State__r.Country__c,
        Distribution_Center__c, Pricebook2Id, EffectiveDate, Status
    FROM Order
    WHERE Status = 'Draft'
        AND Order_Number_Representative__c = 'PRICING-TRIGGER-SEED'
        AND Account_Address__c != null
        AND Account_Address__r.City__c != null
        AND Account_Address__r.City__r.State__c != null
        AND Distribution_Center__c != null
        AND Pricebook2Id != null
        AND Account.Account_Group__c != null
    LIMIT 1
];
System.assert(
    !orderFixtures.isEmpty(),
    'Configure at least one Draft Order with address, distribution center, account group, and pricebook.'
);
Order orderFixture = orderFixtures[0];

List<PricebookEntry> productFixtures = [
    SELECT Id, Product2Id, Product2.Product_Hierarchy__c,
        Product2.Production_Cost__c
    FROM PricebookEntry
    WHERE Pricebook2Id = :orderFixture.Pricebook2Id
        AND IsActive = true
        AND Product2.IsActive = true
        AND Product2.Product_Hierarchy__c != null
        AND Product2.Production_Cost__c > 0
    LIMIT 1
];
System.assert(
    !productFixtures.isEmpty(),
    'Add an active product with hierarchy and production cost to the Order pricebook.'
);
PricebookEntry productPrice = productFixtures[0];
Id cityId = orderFixture.Account_Address__r.City__c;
Id stateId = orderFixture.Account_Address__r.City__r.State__c;
Id countryId = orderFixture.Account_Address__r.City__r.State__r.Country__c;
OrderItem selectionItem = new OrderItem(Product2Id = productPrice.Product2Id);
MarginService marginService = new MarginService();
Margin__c selectedMargin = marginService.getSpecificMargin(
    selectionItem,
    productPrice.Product2,
    orderFixture,
    new List<Margin__c>{
        new Margin__c(
            Product_Hierarchy__c = productPrice.Product2.Product_Hierarchy__c,
            Account_Group__c = orderFixture.Account.Account_Group__c,
            Distribution_Center__c = orderFixture.Distribution_Center__c,
            Country__c = countryId,
            Value__c = 0.10
        ),
        new Margin__c(
            Product__c = productPrice.Product2Id,
            Account__c = orderFixture.AccountId,
            Distribution_Center__c = orderFixture.Distribution_Center__c,
            City__c = cityId,
            Value__c = 0.25
        )
    }
);
Boolean marginSpecificityPassed =
    selectedMargin != null && selectedMargin.Value__c == 0.25;
executed++;
if (!marginSpecificityPassed) {
    failures++;
}
System.debug(
    (marginSpecificityPassed ? '[PASS] ' : '[FAIL] ')
        + 'Margem: priorizar produto, conta e cidade mais específicos'
);

FreightService freightService = new FreightService();
Freight__c selectedFreight = freightService.getSpecificFreight(
    selectionItem,
    productPrice.Product2,
    orderFixture,
    new List<Freight__c>{
        new Freight__c(
            Product_Hierarchy__c = productPrice.Product2.Product_Hierarchy__c,
            Distribution_Center__c = orderFixture.Distribution_Center__c,
            Country__c = countryId,
            Value__c = 10
        ),
        new Freight__c(
            Product__c = productPrice.Product2Id,
            Distribution_Center__c = orderFixture.Distribution_Center__c,
            City__c = cityId,
            Value__c = 20
        )
    }
);
Boolean freightSpecificityPassed =
    selectedFreight != null && selectedFreight.Value__c == 20;
executed++;
if (!freightSpecificityPassed) {
    failures++;
}
System.debug(
    (freightSpecificityPassed ? '[PASS] ' : '[FAIL] ')
        + 'Frete: priorizar produto e cidade sobre hierarquia e país'
);

List<Tax__c> taxSelectionCandidates = new List<Tax__c>{
    new Tax__c(
        Product__c = productPrice.Product2Id,
        State__c = stateId,
        Tax_on_Cost__c = 0.03
    ),
    new Tax__c(
        Product__c = productPrice.Product2Id,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        State__c = stateId,
        Tax_on_Cost__c = 0.07
    )
};
TaxService taxService = new TaxService();
Tax__c selectedTax = taxService.getSpecificTax(
    selectionItem,
    orderFixture,
    taxSelectionCandidates
);
Tax__c unmatchedTax = taxService.getSpecificTax(
    selectionItem,
    orderFixture,
    new List<Tax__c>{ taxSelectionCandidates[0] }
);
Boolean taxSpecificityPassed =
    selectedTax != null && selectedTax.Tax_on_Cost__c == 0.07
    && unmatchedTax == null;
executed++;
if (!taxSpecificityPassed) {
    failures++;
}
System.debug(
    (taxSpecificityPassed ? '[PASS] ' : '[FAIL] ')
        + 'Imposto: exigir produto, centro e estado correspondentes'
);

String productValidationError =
    'Preencha um produto ou uma Hierarquia de produto. (Apenas um deles pode ser preenchido.)';
String localityValidationError =
    'Preencha uma cidade, um estado ou um país. (Apenas um deles pode ser preenchido.)';

List<Freight__c> freightCases = new List<Freight__c>{
    new Freight__c(
        Product__c = productPrice.Product2Id,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 15,
        City__c = cityId
    ),
    new Freight__c(
        Product__c = productPrice.Product2Id,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 15,
        City__c = cityId
    ),
    new Freight__c(
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 15,
        City__c = cityId
    ),
    new Freight__c(
        Product__c = productPrice.Product2Id,
        Product_Hierarchy__c = productPrice.Product2.Product_Hierarchy__c,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 15,
        City__c = cityId
    ),
    new Freight__c(
        Product__c = productPrice.Product2Id,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 15
    ),
    new Freight__c(
        Product__c = productPrice.Product2Id,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 15,
        State__c = stateId,
        Country__c = countryId
    )
};
List<String> freightCaseNames = new List<String>{
    'Frete: produto + cidade válidos',
    'Frete: rejeitar combinação duplicada',
    'Frete: produto e hierarquia ausentes',
    'Frete: produto e hierarquia preenchidos',
    'Frete: localidade ausente',
    'Frete: estado e país preenchidos'
};
List<Boolean> freightExpectedSuccess = new List<Boolean>{
    true,
    false,
    false,
    false,
    false,
    false
};
List<String> freightExpectedErrors = new List<String>{
    null,
    null,
    productValidationError,
    productValidationError,
    localityValidationError,
    localityValidationError
};

for (Integer i = 0; i < freightCases.size(); i++) {
    Database.SaveResult result = Database.insert(freightCases[i], false);
    Boolean expectedSuccess = freightExpectedSuccess[i];
    String actualError = result.isSuccess()
        ? null
        : result.getErrors()[0].getMessage();
    Boolean passed = result.isSuccess() == expectedSuccess
        && (
            expectedSuccess
                || freightExpectedErrors[i] == null
                || actualError.contains(freightExpectedErrors[i])
        );
    executed++;
    if (passed && i == 0) {
        validFreightId = result.getId();
    }
    if (!passed) {
        failures++;
    }
    System.debug(
        (passed ? '[PASS] ' : '[FAIL] ')
            + freightCaseNames[i]
            + (actualError == null ? '' : ' | ' + actualError)
    );
}

List<Margin__c> marginCases = new List<Margin__c>{
    new Margin__c(
        Product__c = productPrice.Product2Id,
        Account_Group__c = orderFixture.Account.Account_Group__c,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 0.10,
        State__c = stateId
    ),
    new Margin__c(
        Product__c = productPrice.Product2Id,
        Account_Group__c = orderFixture.Account.Account_Group__c,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 0.10,
        State__c = stateId
    ),
    new Margin__c(
        Account_Group__c = orderFixture.Account.Account_Group__c,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 0.10,
        State__c = stateId
    ),
    new Margin__c(
        Product__c = productPrice.Product2Id,
        Product_Hierarchy__c = productPrice.Product2.Product_Hierarchy__c,
        Account_Group__c = orderFixture.Account.Account_Group__c,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 0.10,
        State__c = stateId
    ),
    new Margin__c(
        Product__c = productPrice.Product2Id,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 0.10,
        State__c = stateId
    ),
    new Margin__c(
        Product__c = productPrice.Product2Id,
        Account__c = orderFixture.AccountId,
        Account_Group__c = orderFixture.Account.Account_Group__c,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 0.10,
        State__c = stateId
    ),
    new Margin__c(
        Product__c = productPrice.Product2Id,
        Account_Group__c = orderFixture.Account.Account_Group__c,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 0.10
    ),
    new Margin__c(
        Product__c = productPrice.Product2Id,
        Account_Group__c = orderFixture.Account.Account_Group__c,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        Status__c = 'Approved',
        Value__c = 0.10,
        City__c = cityId,
        State__c = stateId
    )
};
List<String> marginCaseNames = new List<String>{
    'Margem: produto + grupo + estado válidos',
    'Margem: rejeitar combinação duplicada',
    'Margem: produto e hierarquia ausentes',
    'Margem: produto e hierarquia preenchidos',
    'Margem: conta e grupo ausentes',
    'Margem: conta e grupo preenchidos',
    'Margem: localidade ausente',
    'Margem: cidade e estado preenchidos'
};
List<Boolean> marginExpectedSuccess = new List<Boolean>{
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false
};
List<String> marginExpectedErrors = new List<String>{
    null,
    null,
    productValidationError,
    productValidationError,
    'Preencha uma conta ou um Grupo de contas. (Apenas um deles pode ser preenchido.)',
    'Preencha uma conta ou um Grupo de contas. (Apenas um deles pode ser preenchido.)',
    localityValidationError,
    localityValidationError
};

for (Integer i = 0; i < marginCases.size(); i++) {
    Database.SaveResult result = Database.insert(marginCases[i], false);
    Boolean expectedSuccess = marginExpectedSuccess[i];
    String actualError = result.isSuccess()
        ? null
        : result.getErrors()[0].getMessage();
    Boolean passed = result.isSuccess() == expectedSuccess
        && (
            expectedSuccess
                || marginExpectedErrors[i] == null
                || actualError.contains(marginExpectedErrors[i])
        );
    executed++;
    if (passed && i == 0) {
        validMarginId = result.getId();
    }
    if (!passed) {
        failures++;
    }
    System.debug(
        (passed ? '[PASS] ' : '[FAIL] ')
            + marginCaseNames[i]
            + (actualError == null ? '' : ' | ' + actualError)
    );
}

List<Account> otherAccounts = [
    SELECT Id
    FROM Account
    WHERE Id != :orderFixture.AccountId
    LIMIT 1
];
if (!otherAccounts.isEmpty()) {
    Order changedAccount = new Order(
        Id = orderFixture.Id,
        AccountId = otherAccounts[0].Id
    );
    Database.SaveResult result = Database.update(changedAccount, false);
    String expectedError = 'Não é possivel alterar a conta do pedido após sua criação';
    String actualError = result.isSuccess()
        ? null
        : result.getErrors()[0].getMessage();
    Boolean passed = !result.isSuccess() && actualError.contains(expectedError);
    executed++;
    if (!passed) {
        failures++;
    }
    System.debug(
        (passed ? '[PASS] ' : '[FAIL] ')
            + 'Pedido: bloquear alteração da conta'
            + (actualError == null ? '' : ' | ' + actualError)
    );
} else {
    System.debug('[SKIP] Pedido: não há outra conta cadastrada para testar.');
}

if (validFreightId != null && validMarginId != null) {
    Tax__c taxFixture = new Tax__c(
        Product__c = productPrice.Product2Id,
        Distribution_Center__c = orderFixture.Distribution_Center__c,
        State__c = stateId,
        Status__c = 'Approved',
        Tax_on_Cost__c = 0.07
    );
    Database.SaveResult taxResult = Database.insert(taxFixture, false);
    if (taxResult.isSuccess()) {
        List<OrderItem> orderItemCases = new List<OrderItem>{
            new OrderItem(
                OrderId = orderFixture.Id,
                PricebookEntryId = productPrice.Id,
                Quantity = 1
            ),
            new OrderItem(
                OrderId = orderFixture.Id,
                PricebookEntryId = productPrice.Id,
                Quantity = 0
            ),
            new OrderItem(
                OrderId = orderFixture.Id,
                PricebookEntryId = productPrice.Id,
                Quantity = 1,
                UnitPrice = 0
            )
        };
        List<String> orderItemCaseNames = new List<String>{
            'Item do pedido: aceitar quantidade e preço positivos',
            'Item do pedido: rejeitar quantidade zero',
            'Item do pedido: recalcular preço com UnitPrice informado como zero'
        };
        List<Boolean> orderItemExpectedSuccess = new List<Boolean>{
            true,
            false,
            true
        };
        Database.SaveResult[] itemResults = Database.insert(orderItemCases, false);
        for (Integer i = 0; i < itemResults.size(); i++) {
            Boolean passed = itemResults[i].isSuccess()
                == orderItemExpectedSuccess[i];
            executed++;
            if (!passed) {
                failures++;
            }
            System.debug(
                (passed ? '[PASS] ' : '[FAIL] ')
                    + orderItemCaseNames[i]
                    + (
                        itemResults[i].isSuccess()
                            ? ''
                            : ' | ' + itemResults[i].getErrors()[0].getMessage()
                    )
            );
        }

        if (itemResults[0].isSuccess()) {
            OrderItem insertedItem = [
                SELECT Id, UnitPrice, Price_without_Margin__c,
                    Margin_Percentage__c, Shipping_Cost__c, Tax_Percentage__c,
                    Discount__c, Final_Price__c
                FROM OrderItem
                WHERE Id = :itemResults[0].getId()
            ];
            Decimal expectedPriceWithoutMargin =
                (productPrice.Product2.Production_Cost__c + 15) * 1.07;
            Decimal expectedFinalPrice = expectedPriceWithoutMargin * 1.10;
            Boolean copiedInputsMatch =
                insertedItem.Margin_Percentage__c == 0.10
                && insertedItem.Shipping_Cost__c == 15
                && insertedItem.Tax_Percentage__c == 0.07;
            Boolean calculatedPricesMatch =
                insertedItem.Price_without_Margin__c == expectedPriceWithoutMargin
                && insertedItem.UnitPrice == expectedFinalPrice;
            Decimal expectedDiscount = 0;
            Boolean discountMatches = insertedItem.Discount__c != null
                && Math.abs(insertedItem.Discount__c - expectedDiscount) < 0.0001
                && insertedItem.Final_Price__c == expectedFinalPrice;
            executed += 3;
            if (!copiedInputsMatch) {
                failures++;
            }
            if (!calculatedPricesMatch) {
                failures++;
            }
            if (!discountMatches) {
                failures++;
            }
            System.debug(
                (copiedInputsMatch ? '[PASS] ' : '[FAIL] ')
                    + 'Item do pedido: copiar margem, frete e imposto'
            );
            System.debug(
                (calculatedPricesMatch ? '[PASS] ' : '[FAIL] ')
                    + 'Item do pedido: calcular preço sem margem e preço final'
                    + ' | esperado=' + expectedPriceWithoutMargin
                    + '/' + expectedFinalPrice
                    + ' | obtido=' + insertedItem.Price_without_Margin__c
                    + '/' + insertedItem.UnitPrice
            );
            System.debug(
                (discountMatches ? '[PASS] ' : '[FAIL] ')
                    + 'Item do pedido: aplicar desconto padrão de zero'
                    + ' | esperado=' + expectedDiscount
                    + ' | obtido=' + insertedItem.Discount__c
                    + ' | preço final=' + insertedItem.Final_Price__c
            );

            Boolean zeroInputPriceRecalculated = false;
            if (itemResults[2].isSuccess()) {
                OrderItem zeroInputPriceItem = [
                    SELECT UnitPrice, Final_Price__c
                    FROM OrderItem
                    WHERE Id = :itemResults[2].getId()
                ];
                zeroInputPriceRecalculated =
                    zeroInputPriceItem.UnitPrice == expectedFinalPrice
                    && zeroInputPriceItem.Final_Price__c == expectedFinalPrice;
            }
            executed++;
            if (!zeroInputPriceRecalculated) {
                failures++;
            }
            System.debug(
                (zeroInputPriceRecalculated ? '[PASS] ' : '[FAIL] ')
                    + 'Item do pedido: recalcular preço informado como zero'
            );

            OrderItem editItem = new OrderItem(
                Id = insertedItem.Id,
                Quantity = 2,
                Discount__c = 0.10
            );
            Database.SaveResult updateResult = Database.update(editItem, false);
            Boolean updated = false;
            Decimal expectedUpdatedUnitPrice =
                (productPrice.Product2.Production_Cost__c + 15) * 1.07 * 1.10;
            Decimal expectedUpdatedFinalPrice =
                expectedUpdatedUnitPrice * 2 * 0.90;
            if (updateResult.isSuccess()) {
                OrderItem updatedItem = [
                    SELECT UnitPrice, Price_without_Margin__c, Final_Price__c
                    FROM OrderItem
                    WHERE Id = :insertedItem.Id
                ];
                Boolean updatedUnitPriceMatches =
                    updatedItem.UnitPrice != null
                    && Math.abs(
                        updatedItem.UnitPrice - expectedUpdatedUnitPrice
                    ) < 0.01;
                Boolean updatedPriceWithoutMarginMatches =
                    updatedItem.Price_without_Margin__c != null
                    && Math.abs(
                        updatedItem.Price_without_Margin__c - expectedPriceWithoutMargin
                    ) < 0.01;
                Boolean updatedFinalPriceMatches =
                    updatedItem.Final_Price__c != null
                    && Math.abs(
                        updatedItem.Final_Price__c - expectedUpdatedFinalPrice
                    ) < 0.01;
                updated = updatedUnitPriceMatches
                    && updatedPriceWithoutMarginMatches
                    && updatedFinalPriceMatches;
                System.debug(
                    'Recalculo apos atualizacao | UnitPrice esperado/obtido='
                        + expectedUpdatedUnitPrice + '/'
                        + updatedItem.UnitPrice
                        + ' | Price_without_Margin__c esperado/obtido='
                        + expectedPriceWithoutMargin + '/'
                        + updatedItem.Price_without_Margin__c
                        + ' | Final_Price__c esperado/obtido='
                        + expectedUpdatedFinalPrice + '/'
                        + updatedItem.Final_Price__c
                );
            }
            executed++;
            if (!updated) {
                failures++;
            }
            System.debug(
                (updated ? '[PASS] ' : '[FAIL] ')
                    + 'Item do pedido: recalcular preço após atualização'
                    + (updateResult.isSuccess()
                        ? ''
                        : ' | ' + updateResult.getErrors()[0].getMessage())
            );

            Order activateFixture = new Order(
                Id = orderFixture.Id,
                Status = 'Activated'
            );
            Database.SaveResult activationResult = Database.update(
                activateFixture,
                false
            );
            executed++;
            if (!activationResult.isSuccess()) {
                failures++;
            }
            System.debug(
                (activationResult.isSuccess() ? '[PASS] ' : '[FAIL] ')
                    + 'Pedido: ativar o pedido de teste'
                    + (activationResult.isSuccess()
                        ? ''
                        : ' | ' + activationResult.getErrors()[0].getMessage())
            );
            if (activationResult.isSuccess()) {
                Order activatedFixture = [
                    SELECT EffectiveDate
                    FROM Order
                    WHERE Id = :orderFixture.Id
                ];
                Order changeActivatedFixture = new Order(
                    Id = orderFixture.Id,
                    EffectiveDate = activatedFixture.EffectiveDate.addDays(1)
                );
                Database.SaveResult activatedUpdateResult = Database.update(
                    changeActivatedFixture,
                    false
                );
                String expectedError =
                    'Não é possivel alterar um pedido já ativo!';
                String activatedUpdateError = activatedUpdateResult.isSuccess()
                    ? null
                    : activatedUpdateResult.getErrors()[0].getMessage();
                Boolean activatedUpdatePassed =
                    !activatedUpdateResult.isSuccess()
                    && activatedUpdateError.contains(expectedError);
                executed++;
                if (!activatedUpdatePassed) {
                    failures++;
                }
                System.debug(
                    (activatedUpdatePassed ? '[PASS] ' : '[FAIL] ')
                        + 'Pedido: bloquear alteração após ativação'
                        + (
                            activatedUpdateError == null
                                ? ''
                                : ' | ' + activatedUpdateError
                        )
                );
            }
        }
    } else {
        System.debug(
            '[SKIP] Item do pedido: não foi possível criar o imposto de teste: '
                + taxResult.getErrors()[0].getMessage()
        );
    }
} else {
    System.debug(
        '[SKIP] Item do pedido: falhou a criação do frete ou da margem de teste.'
    );
}

Database.rollback(testSavepoint);
System.debug(
    'Resultado: ' + (executed - failures) + '/' + executed
        + ' casos passaram; ' + failures + ' falharam. Dados temporários revertidos.'
);
System.assertEquals(0, failures, 'Há casos de trigger que não atendem ao esperado.');
