public with sharing class AssociatedTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {

        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();

        for (AssociatedLocation al : (List<AssociatedLocation>) Trigger.new) {

            if (al.ParentRecordId != null && al.UserId__c != null) {
                accountIds.add(al.ParentRecordId);
                userIds.add(al.UserId__c);
            }
        }

        if (accountIds.isEmpty() || userIds.isEmpty()) {
            return;
        }

        Set<Id> existingAccountMembers = new Set<Id>();
        Set<Id> existingUserMembers = new Set<Id>();

        for (AccountTeamMember atm : [SELECT AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND UserId IN :userIds]) {
            existingAccountMembers.add(atm.AccountId);
            existingUserMembers.add(atm.UserId);
        }

        List<AccountTeamMember> membersToInsert = new List<AccountTeamMember>();

        for (AssociatedLocation al : (List<AssociatedLocation>) Trigger.new) {

            if (al.ParentRecordId == null || al.UserId__c == null) {
                continue;
            }
            Id userMemberId = al.UserId__c;
            Id accountMemberId = al.ParentRecordId;

            if (!existingUserMembers.contains(userMemberId) && !existingAccountMembers.contains(accountMemberId)) {
                membersToInsert.add(new AccountTeamMember(AccountId = al.ParentRecordId, UserId = al.UserId__c));

                existingUserMembers.add(userMemberId);
                existingAccountMembers.add(accountMemberId);
            }
        }

        if (!membersToInsert.isEmpty()) {
            insert membersToInsert;
        }
    }


    public override void afterUpdate() {
        List<AssociatedLocation> newAls = (List<AssociatedLocation>) Trigger.new;
        List<AssociatedLocation> oldAls = (List<AssociatedLocation>) Trigger.old;

        List<AccountTeamMember> atmsToAdd = new List<AccountTeamMember>();
        List<AccountTeamMember> atmsToDelete = new List<AccountTeamMember>();

        for(AssociatedLocation usrAl : newAls) {
            //Update do User
            AssociatedLocation usrOldAl = oldAls[oldAls.indexOf(usrAl)];
            
            if(usrOldAl == null) {
                continue;
            }

            if(usrAl.UserId__c != usrOldAl.UserId__c) {
                atmsToAdd.add(new AccountTeamMember(AccountId = usrAl.ParentRecordId, UserId = usrAl.UserId__c));
                for(AssociatedLocation usrLa : oldAls) {
                    if(usrLa.UserId__c != usrOldAl.UserId__c) {
                        AccountTeamMember atm = [SELECT Id FROM AccountTeamMember WHERE UserId = :usrOldAl.UserId__c LIMIT 1];
                        delete atm;
                    }
                }
            }

            insert atmsToAdd;

            //Update da Account 
            for(AssociatedLocation accAl : newAls) {
                AssociatedLocation accOldAl = oldAls[oldAls.indexOf(accAl)];
            
                if(accOldAl == null) {
                    continue;
                }

                if(accAl.ParentRecordId != accOldAl.ParentRecordId) {
                    for(AssociatedLocation accLa : oldAls) {
                        if(accLa.UserId__c == accOldAl.UserId__c) {
                            continue;
                        } else {
                            atmsToDelete.add(new AccountTeamMember(AccountId = accLa.ParentRecordId, UserId = accLa.UserId__c));
                        }
                    }
                        delete atmsToDelete;
                    }
                insert atmsToAdd;
            }
        }
        
    }

    public override void afterDelete() {
        for(AssociatedLocation al : (List<AssociatedLocation>) Trigger.old) {
            if([SELECT Id FROM AssociatedLocation WHERE ParentRecordId = :al.ParentRecordId].isEmpty()) {
                List<Account> acc = [SELECT Id FROM Account WHERE OwnerId = :al.UserId__c LIMIT 1];
                acc[0].OwnerId = null;
                update acc[0];
            }
        }
    }
}