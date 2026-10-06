public with sharing class TaskTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        Set<Id> taskWhatIds = new Set<Id>();
        for(Task t : (List<Task>) Trigger.new) {
            if(t.Status == 'Not Started' || t.Status == 'In Progress' || t.Status == 'Waiting on someone else' && t.WhatId.getSobjectType() == Case.getSObjectType()) {
                taskWhatIds.add(t.WhatId);
            }
        }
        for(Case c : [SELECT Id FROM Case WHERE Id IN :taskWhatIds]) {
            for(Task t : (List<Task>) Trigger.new) {
                if(t.WhatId == c.Id) {
                    t.addError('Já existe uma tarefa em aberto nesse caso. Encerre-a antes de abrir uma nova.');
                }
            }
        }
    }
}