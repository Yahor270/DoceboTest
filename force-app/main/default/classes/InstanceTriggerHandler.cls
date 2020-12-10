public with sharing class InstanceTriggerHandler {

    public static void addNewLicences(List<Instance__c> newInstances) {
        
        Map<Id, Decimal> accountMap = new Map<Id, Decimal>();
        //calculating overal quantity of new liceneces for each account
        for(Instance__c inst : newInstances) {
            if(inst.Type__c == 'Standard') {
                if(accountMap.get(inst.Account__c) != null) {
                    Decimal currentValue = accountMap.get(inst.Account__c);
                    accountMap.put(inst.Account__c, currentValue + inst.Number_of_Licences__c);
                } else {
                    accountMap.put(inst.Account__c, inst.Number_of_Licences__c);
                }
            }
        }

        if(accountMap.keyset().isEmpty()) {
            return;
        }

        updateAccounts(accountMap);
    }

    public static void updateLicencesNumber(Map<Id, Instance__c> oldInstances, Map<Id, Instance__c> newInstances) {

        Map<Id, Decimal> deltaMap = new Map<Id, Decimal>();
        //calculating licences delta for each account
        for(Id instId : newInstances.keyset()) {
            //for instances which remained their type
            if(newInstances.get(instId).Type__c == 'Standard' && oldInstances.get(instId).Type__c == 'Standard') {
                Decimal delta = newInstances.get(instId).Number_of_Licences__c - oldInstances.get(instId).Number_of_Licences__c;
                if(deltaMap.get(newInstances.get(instId).Account__c) != null) {
                    Decimal currentValue = deltaMap.get(newInstances.get(instId).Account__c);
                    deltaMap.put(newInstances.get(instId).Account__c, currentValue + delta);
                } else {
                    deltaMap.put(newInstances.get(instId).Account__c, delta);
                }
            } else if(newInstances.get(instId).Type__c == 'Standard' && oldInstances.get(instId).Type__c == 'Trial') {
                 //for instances which changed their type to standard
                if(deltaMap.get(newInstances.get(instId).Account__c) != null) {
                    Decimal currentValue = deltaMap.get(newInstances.get(instId).Account__c);
                    deltaMap.put(newInstances.get(instId).Account__c, currentValue + newInstances.get(instId).Number_of_Licences__c);
                } else {
                    deltaMap.put(newInstances.get(instId).Account__c, newInstances.get(instId).Number_of_Licences__c);
                }
            }
        }

        if(deltaMap.keyset().isEmpty()) {
            return;
        }

        updateAccounts(deltaMap);
    }

    public static void removeLicences(List<Instance__c> deletedInstances) {

        Map<Id, Decimal> accountMap = new Map<Id, Decimal>();
        //calculating overal quantity of liceneces to delete for each account
        for(Instance__c inst : deletedInstances) {
            if(inst.Type__c == 'Standard') {
                if(accountMap.get(inst.Account__c) != null) {
                    Decimal currentValue = accountMap.get(inst.Account__c);
                    accountMap.put(inst.Account__c, currentValue - inst.Number_of_Licences__c);
                } else {
                    accountMap.put(inst.Account__c, inst.Number_of_Licences__c * -1);
                }
            }
        }

        if(accountMap.keyset().isEmpty()) {
            return;
        }

        updateAccounts(accountMap);
    }

    public static void removeInstances(Map<Id, Account> deletedAccounts) {
        
        List<Instance__c> instToDelete = new List<Instance__c>();
        instToDelete = [SELECT Id FROM Instance__c WHERE Account__c IN : deletedAccounts.keyset()];

        delete instToDelete;
    }

    private static void updateAccounts(Map<Id, Decimal> accountMap) {
        
        List<Account> accountsToUpd = [SELECT Id, Total_Licences__c FROM Account WHERE Id IN : accountMap.keyset()];

        for(Account acc : accountsToUpd) {
            Decimal currentNumber = (acc.Total_Licences__c != null ? acc.Total_Licences__c : 0);
            acc.Total_Licences__c = currentNumber + accountMap.get(acc.Id);
        }

        update accountsToUpd;
    }
}