trigger AccountTrigger on Account (after delete) {
    
    if(Trigger.isDelete) {
        InstanceTriggerHandler.removeInstances(Trigger.oldMap);
    }
}