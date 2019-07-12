public with sharing class TimecardsAppController {

    /*
        creating a wrapper class to represent the Opportunity
        to avoid letting a Guest User (via Sites) have Read
        access to the Opportunity object, and sharing these
        records with that particular user
    */
    public class Grant {
        @AuraEnabled public String grantName;
        @AuraEnabled public Id grantId;
    }
    
    /*
        input: Contact ID
        return: a collection of Grant records where that Contact
                ID is populated in the lookup on Staff__c records
    */
    @AuraEnabled(cacheable=true)
    public static List<Grant> getGrants(Id contactId) {
        
        // create return collection
        List<Grant> grants = new List<Grant>();

        /*
            retrieve all Opportunity records where the Contact ID 
            is part of Staff__c records
        */
        List<Opportunity> opps = getOpportunities(contactId);

        for(Opportunity opp : opps) {

            Grant grant = new Grant();
            grant.grantId = opp.Id;
            grant.grantName = opp.Name;
            grants.add(grant);
        }

        return grants;
    }
    
    /*
        input: Grant ID
        return: a collection of Grant_Work_Items__c records
                related to that Opportunity (Grant) record
    */
    @AuraEnabled(cacheable=true)
    public static List<Grant_Work_Items__c> getGrantWorkItems(Id grantId) {

        return [SELECT Id, Name FROM Grant_Work_Items__c WHERE Grant__c = :grantId ORDER BY Name];
    }

    /*
        input: Timecards__c SObject as JSON string
        return: ¯\_(ツ)_/¯
    */
    @AuraEnabled
    public static void saveTimecardsRecord(String jsonString) {
        
        // deserialize this string into a Timecards__c class
        Timecards__c timecard = (Timecards__c) JSON.deserialize(jsonString, Timecards__c.class);

        // insert this record
        insert timecard;
    }

    private static List<Opportunity> getOpportunities(Id contactId) {

        return [SELECT Id, Name FROM Opportunity WHERE Id IN (SELECT Grant__c FROM Staff__c WHERE Contact__c = :contactId) ORDER BY Name];
    }
}