@isTest
public with sharing class TimecardsAppController_TEST {
    
    @TestSetup
    static void testSetup() {
        
        // create new Account
        Account account = new Account();
        account.Name = 'Staff Contacts Placeholder';
        insert account;

        // create some Contacts
        List<Contact> contacts = new List<Contact>();

        for(Integer i = 0; i < 5; i += 1) {

            Contact contact = new Contact();
            contact.FirstName = 'Test ' + i;
            contact.LastName = 'Test ' + i;
            contact.AccountId = account.Id;
            contacts.add(contact);
        }

        insert contacts;

        // create some Opportunities
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0; i < 10; i += 1) {

            Opportunity opp = new Opportunity();
            opp.Name = 'Test ' + i;
            opp.StageName = 'Closed Won';
            opp.CloseDate = Date.today();
            opps.add(opp);
        }
        
        insert opps;

        // create some Grant Work Items
        List<Grant_Work_Items__c> grantWorkItems = new List<Grant_Work_Items__c>();

        for(Opportunity opp : opps) {

            for(Integer i = 0; i < 2; i += 1) {

                Grant_Work_Items__c grantWorkItem = new Grant_Work_Items__c();
                grantWorkItem.Grant__c = opp.Id;
                grantWorkItem.Name = 'Test ' + i;
                grantWorkItems.add(grantWorkItem);
            }
        }

        insert grantWorkItems;

        // create some Staff
        List<Staff__c> staffs = new List<Staff__c>();

        for(Opportunity opp : opps) {

            for(Contact contact : contacts) {

                Staff__c staff = new Staff__c();
                staff.Contact__c = contact.Id;
                staff.Grant__c = opp.Id;
                staffs.add(staff);
            }
        }

        insert staffs;
    }

    @isTest
    static void testGetGrants() {

        // grab a random Contact ID that exists on Staff__c
        Id contactId = [SELECT Contact__c FROM Staff__c LIMIT 1].Contact__c;

        // this should not be null
        System.assert(contactId != null);

        // retrieve a list of Grants from the controller
        List<TimecardsAppController.Grant> grants = TimecardsAppController.getGrants(contactId);

        // get a collection of Grants
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Id IN (SELECT Grant__c FROM Staff__c WHERE Contact__c = :contactId)];

        // these should be the same size
        System.assertEquals(opps.size(), grants.size());
    }

    @isTest
    static void testGetGrantWorkItems() {

        // grab a random Grant ID
        Id grantId = [SELECT Grant__c FROM Grant_Work_Items__c LIMIT 1].Grant__c;

        // this should not be null
        System.assert(grantId != null);

        // retrieve a list of Grant_Work_Items__c from the controller
        List<Grant_Work_Items__c> grantWorkItems = TimecardsAppController.getGrantWorkItems(grantId);

        // get a collection of Grant_Work_Items__c for that particular Grant
        List<Grant_Work_Items__c> grantWorkItemsVerify = [SELECT Id FROM Grant_Work_Items__c WHERE Grant__c = :grantId];

        // these should be the same size
        System.assertEquals(grantWorkItemsVerify.size(), grantWorkItems.size());
    }

    @isTest
    static void testSaveTimecardsRecord() {

         // grab a random Contact ID that exists on Staff__c
        Id contactId = [SELECT Contact__c FROM Staff__c LIMIT 1].Contact__c;

        // grab a random Grant ID
        Id grantId = [SELECT Grant__c FROM Grant_Work_Items__c LIMIT 1].Grant__c;

        // create a Timecards__c record
        Timecards__c timecard = new Timecards__c();
        timecard.Grant__c = grantId;
        timecard.Contact__c = contactId;
        timecard.Date__c = Date.today();
        timecard.Hours__c = 8;

        // create a JSON string from this
        String jsonString = JSON.serialize(timecard);

        // pass this string into the controller method
        TimecardsAppController.saveTimecardsRecord(jsonString);
    }
}