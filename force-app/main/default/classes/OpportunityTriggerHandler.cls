public with sharing class OpportunityTriggerHandler {

    public static void createInstances(List<Opportunity> newOpportunities) {
        List<Opportunity> wonOpps = new List<Opportunity>();
        for(Opportunity opp : newOpportunities) {
            if(opp.IsWon) {
                wonOpps.add(opp);
            }
        }

        if(wonOpps.isEmpty()) {
            return;
        }

        List<Opportunity> oppsWithAccountNames = [SELECT AccountId, Account.Name, Total_Quantity__c FROM Opportunity WHERE ID IN : wonOpps];

        List<Instance__c> newInstances = new List<Instance__c>();
        for(Opportunity opp : oppsWithAccountNames) {
            newInstances.add(makeInstance(opp));
        }

        insert newInstances;
    }

    private static Instance__c makeInstance(Opportunity newOpp) {
        Instance__c newInst = new Instance__c();
        newInst.Name = newOpp.Account.Name + ' Standard Instance';
        newInst.Type__c = 'Standard';
        newInst.Account__c = newOpp.AccountId;
        newInst.Number_of_Licences__c = newOpp.Total_Quantity__c;
      
        return newInst;
    }
}