trigger InstanceTrigger on Instance__c (after insert, after update, after delete) {
    
    if(Trigger.isInsert) {
        InstanceTriggerHandler.addNewLicences(Trigger.new);
    }
    if(Trigger.isUpdate) {
        InstanceTriggerHandler.updateLicencesNumber(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isDelete) {
        InstanceTriggerHandler.removeLicences(Trigger.old);
    }
}