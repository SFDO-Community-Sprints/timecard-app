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
}
