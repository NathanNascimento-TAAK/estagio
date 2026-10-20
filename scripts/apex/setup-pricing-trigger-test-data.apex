// Run once before test-pricing-triggers.apex:
// sf apex run --target-org <alias> --file scripts/apex/setup-pricing-trigger-test-data.apex
// This script creates persistent seed records. The trigger test script rolls
// back only its own test data, not these fixtures.
String seedOrderNumber = 'PRICING-TRIGGER-SEED';
List<Order> existingSeeds = [
    SELECT Id
    FROM Order
    WHERE Order_Number_Representative__c = :seedOrderNumber
    LIMIT 1
];

if (!existingSeeds.isEmpty()) {
    System.debug(
        'A base de teste já existe. Pedido: ' + existingSeeds[0].Id
    );
} else {
    String cnpjBase = Datetime.now().formatGMT('yyMMddHHmmss');
    List<Integer> firstWeights = new List<Integer>{5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
    Integer firstSum = 0;
    for (Integer i = 0; i < firstWeights.size(); i++) {
        firstSum += Integer.valueOf(cnpjBase.substring(i, i + 1))
            * firstWeights[i];
    }
    Integer firstRemainder = firstSum - (firstSum / 11) * 11;
    String firstDigit = firstRemainder < 2
        ? '0'
        : String.valueOf(11 - firstRemainder);

    String cnpjFirstThirteen = cnpjBase + firstDigit;
    List<Integer> secondWeights = new List<Integer>{
        6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2
    };
    Integer secondSum = 0;
    for (Integer i = 0; i < secondWeights.size(); i++) {
        secondSum += Integer.valueOf(cnpjFirstThirteen.substring(i, i + 1))
            * secondWeights[i];
    }
    Integer secondRemainder = secondSum - (secondSum / 11) * 11;
    String secondDigit = secondRemainder < 2
        ? '0'
        : String.valueOf(11 - secondRemainder);
    String testCnpjDigits = cnpjFirstThirteen + secondDigit;
    String testCnpj =
        testCnpjDigits.substring(0, 2)
        + '.'
        + testCnpjDigits.substring(2, 5)
        + '.'
        + testCnpjDigits.substring(5, 8)
        + '/'
        + testCnpjDigits.substring(8, 12)
        + '-'
        + testCnpjDigits.substring(12, 14);

    Integer lastBaseDigit = Integer.valueOf(cnpjBase.substring(11, 12));
    Integer otherLastDigit = lastBaseDigit + 1;
    otherLastDigit -= (otherLastDigit / 10) * 10;
    String otherCnpjBase =
        cnpjBase.substring(0, 11) + String.valueOf(otherLastDigit);
    Integer otherFirstSum = 0;
    for (Integer i = 0; i < firstWeights.size(); i++) {
        otherFirstSum += Integer.valueOf(otherCnpjBase.substring(i, i + 1))
            * firstWeights[i];
    }
    Integer otherFirstRemainder =
        otherFirstSum - (otherFirstSum / 11) * 11;
    String otherFirstDigit = otherFirstRemainder < 2
        ? '0'
        : String.valueOf(11 - otherFirstRemainder);
    String otherCnpjFirstThirteen = otherCnpjBase + otherFirstDigit;
    Integer otherSecondSum = 0;
    for (Integer i = 0; i < secondWeights.size(); i++) {
        otherSecondSum += Integer.valueOf(
            otherCnpjFirstThirteen.substring(i, i + 1)
        ) * secondWeights[i];
    }
    Integer otherSecondRemainder =
        otherSecondSum - (otherSecondSum / 11) * 11;
    String otherSecondDigit = otherSecondRemainder < 2
        ? '0'
        : String.valueOf(11 - otherSecondRemainder);
    String otherTestCnpjDigits =
        otherCnpjFirstThirteen + otherSecondDigit;
    String otherTestCnpj =
        otherTestCnpjDigits.substring(0, 2)
        + '.'
        + otherTestCnpjDigits.substring(2, 5)
        + '.'
        + otherTestCnpjDigits.substring(5, 8)
        + '/'
        + otherTestCnpjDigits.substring(8, 12)
        + '-'
        + otherTestCnpjDigits.substring(12, 14);
    String uniqueSuffix = String.valueOf(Datetime.now().getTime());

    Account_Group__c accountGroup = new Account_Group__c(
        Name = 'Grupo de teste Pricing'
    );
    insert accountGroup;

    Country__c country = new Country__c(Name = 'Brasil');
    insert country;

    State__c state = new State__c(
        Name = 'Distrito Federal',
        Sigla__c = 'DF',
        Country__c = country.Id
    );
    insert state;

    City__c city = new City__c(
        Name = 'Brasilia',
        IBGE_Code__c = 5300108,
        State__c = state.Id
    );
    insert city;

    Distribution_Center__c distributionCenter = new Distribution_Center__c(
        Name = 'CD de teste Pricing'
    );
    insert distributionCenter;

    Payment_Term__c paymentTerm = new Payment_Term__c(
        Name = 'A vista - teste'
    );
    insert paymentTerm;

    Account account = new Account(
        Name = 'Conta de teste Pricing ' + uniqueSuffix,
        CNPJ__c = testCnpj,
        Account_Group__c = accountGroup.Id
    );
    insert account;

    Account otherAccount = new Account(
        Name = 'Conta alternativa Pricing ' + uniqueSuffix,
        CNPJ__c = otherTestCnpj,
        Account_Group__c = accountGroup.Id
    );
    insert otherAccount;

    Account_Address__c address = new Account_Address__c(
        Name = 'Endereco de teste ' + uniqueSuffix,
        Street_Address__c = 'Endereco de teste',
        CEP__c = '70000000',
        District__c = 'Centro',
        City__c = city.Id,
        Account__c = account.Id
    );
    insert address;

    Product_Hierarchy__c productHierarchy = new Product_Hierarchy__c(
        Name = 'Hierarquia de teste Pricing'
    );
    insert productHierarchy;

    Product2 product = new Product2(
        Name = 'Produto de teste Pricing ' + uniqueSuffix,
        ProductCode = 'PRICE-' + uniqueSuffix,
        IsActive = true,
        Product_Hierarchy__c = productHierarchy.Id,
        Production_Cost__c = 25
    );
    insert product;

    Pricebook2 standardPricebook = [
        SELECT Id, IsActive
        FROM Pricebook2
        WHERE IsStandard = true
        LIMIT 1
    ];
    if (!standardPricebook.IsActive) {
        standardPricebook.IsActive = true;
        update standardPricebook;
    }

    PricebookEntry pricebookEntry = new PricebookEntry(
        Pricebook2Id = standardPricebook.Id,
        Product2Id = product.Id,
        UnitPrice = 55,
        IsActive = true,
        UseStandardPrice = false
    );
    insert pricebookEntry;

    Order testOrder = new Order(
        AccountId = account.Id,
        Pricebook2Id = standardPricebook.Id,
        EffectiveDate = Date.today(),
        Status = 'Draft',
        Payment_Term__c = paymentTerm.Id,
        Distribution_Center__c = distributionCenter.Id,
        Delivery_Date__c = Datetime.now().addDays(30),
        Account_Address__c = address.Id,
        Order_Number_Representative__c = seedOrderNumber
    );
    insert testOrder;

    System.debug('Base de teste criada.');
    System.debug('Pedido: ' + testOrder.Id);
    System.debug('Conta: ' + account.Id);
    System.debug('Conta alternativa: ' + otherAccount.Id);
    System.debug('Produto: ' + product.Id);
    System.debug('Pricebook padrão: ' + standardPricebook.Id);
    System.debug('PricebookEntry: ' + pricebookEntry.Id);
}
