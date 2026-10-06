@isTest(SeeAllData=false)
private class TriggerBehaviorTest {
    private static final Set<String> BLOCKING_CASE_STATUSES = new Set<String>{
        'Not Started',
        'In Progress',
        'Waiting on someone else'
    };

    @isTest
    static void productInsertCreatesStandardPricebookEntries() {
        Product2 product = new Product2(Name = 'Trigger test product',IsActive = true);

        Test.startTest();
        insert product;
        Test.stopTest();

        List<CurrencyType> activeCurrencies = [
            SELECT IsoCode
            FROM CurrencyType
            WHERE IsActive = true
        ];
        List<PricebookEntry> entries = [
            SELECT Pricebook2Id, UnitPrice, IsActive, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Product2Id = :product.Id
        ];

        System.assertEquals(
            activeCurrencies.size(),
            entries.size(),
            'Deve ser criada uma entrada no pricebook para cada moeda ativa.'
        );
        for (PricebookEntry entry : entries) {
            System.assertEquals(Test.getStandardPricebookId(), entry.Pricebook2Id);
            System.assertEquals(0, entry.UnitPrice);
            System.assertEquals(true, entry.IsActive);
        }
    }

    @isTest
    static void taskInsertIsRejectedForCaseWithBlockingStatus() {
        String blockingStatus = findBlockingCaseStatus();
        System.assertNotEquals(
            null,
            blockingStatus,
            'A organização precisa ter um status de caso que o trigger considera bloqueante.'
        );

        String caseOrigin = findActivePicklistValue(Case.Origin.getDescribe());
        System.assertNotEquals(null, caseOrigin, 'A organização precisa ter uma origem de caso ativa.');

        Account account = new Account(Name = 'Trigger test account');
        insert account;

        Case testCase = new Case(
            AccountId = account.Id,
            Status = blockingStatus,
            Origin = caseOrigin,
            Subject = 'Trigger test case'
        );
        insert testCase;

        Task task = new Task(
            WhatId = testCase.Id,
            Subject = 'Trigger test task',
            Status = 'Not Started',
            Priority = 'Normal'
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(task, false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess(), 'O trigger deveria impedir a tarefa nesse caso.');
        System.assert(
            result.getErrors()[0].getMessage().contains(
                'Já existe uma tarefa em aberto nesse caso.'
            ),
            'A mensagem deve explicar por que a tarefa foi bloqueada.'
        );
    }

    @isTest
    static void associatedLocationInsertWithoutUserDoesNotAddAccountTeamMember() {
        Account account = new Account(Name = 'Trigger test account');
        insert account;

        Schema.Location location = new Schema.Location(Name = 'Trigger test location');
        insert location;

        AssociatedLocation associatedLocation = new AssociatedLocation(
            ParentRecordId = account.Id,
            LocationId = location.Id
        );

        Test.startTest();
        insert associatedLocation;
        Test.stopTest();

        AssociatedLocation insertedRecord = [
            SELECT Id, ParentRecordId, UserId__c
            FROM AssociatedLocation
            WHERE Id = :associatedLocation.Id
        ];
        System.assertEquals(account.Id, insertedRecord.ParentRecordId);
        System.assertEquals(null, insertedRecord.UserId__c);
        System.assertEquals(
            0,
            [SELECT count() FROM AccountTeamMember WHERE AccountId = :account.Id],
            'Sem um usuário associado, o trigger não deve criar membro da equipe.'
        );
    }

    private static String findBlockingCaseStatus() {
        for (Schema.PicklistEntry entry : Task.Status.getDescribe().getPicklistValues()) {
            if (entry.isActive() && BLOCKING_CASE_STATUSES.contains(entry.getValue())) {
                return entry.getValue();
            }
        }
        return null;
    }

    private static String findActivePicklistValue(Schema.DescribeFieldResult fieldDescription) {
        for (Schema.PicklistEntry entry : fieldDescription.getPicklistValues()) {
            if (entry.isActive()) {
                return entry.getValue();
            }
        }
        return null;
    }
}
