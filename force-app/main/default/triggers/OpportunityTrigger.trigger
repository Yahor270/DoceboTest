trigger OpportunityTrigger on Opportunity (after update, after insert) {
   
        OpportunityTriggerHandler.createInstances(Trigger.new);
}