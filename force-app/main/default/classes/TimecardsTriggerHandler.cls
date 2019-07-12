public with sharing class TimecardsTriggerHandler {
    
    public static void handleBeforeInsert(List<Timecards__c> newList) {

        /*
            iterate over Timecards to collect Opportunity and
            Staff Contact IDs, which will be used for retrieving 
            the Staff__c records for each Opportunity
        */
        Set<Id> oppIds = new Set<Id>();

        for(Timecards__c timecard : newList) {
            oppIds.add(timecard.Grant__c);
        }

        oppIds.remove(null);

        /*
            retrieve the list of Staff for each Opportunity, iterate
            over each Timecards__c record to check whether there are
            any Staff__c records for that given Contact where the Date
            falls after the Staff__c record's Start_Date__c and before
            the Staff__c record's End_Date__c

            if there is a matching Staff__c record, we'll set these fields
            on the Timecards__c record and bail out of the loop
            - Salary_Wage_Value__c = Hours__c * Staff__c.Salary_Wage_Rate__c
            - Benefits_Value__c = Hours__c * Staff__c.Benefits_Rate__c
        */
        Map<Id, List<Staff__c>> oppStaff = getOpportunityStaff(oppIds);

        for(Timecards__c timecard : newList) {

            /*
                let's check this Timecards__c to ensure that it has enough
                data to support setting values, our map has this Opportunity
                included, and that collection of related Staff__c is not empty
            */
            if(checkTimecardRequiredFields(timecard)
                && oppStaff.containsKey(timecard.Grant__c)
                && !oppStaff.get(timecard.Grant__c).isEmpty()) {

                for(Staff__c staff : oppStaff.get(timecard.Grant__c)) {

                    /*
                        let's ensure this Staff__c record is the same Contact
                        as our Timecards__c Contact, and the dates are compatible
                        between the Timecards__c and Staff__c
                    */
                    if(timecard.Contact__c == staff.Contact__c
                        && checkTimecardAndStaffDates(timecard, staff)) {

                        if(staff.Benefits_Rate__c != null) {

                            timecard.Benefits_Value__c = timecard.Hours__c * staff.Benefits_Rate__c;
                        }

                        if(staff.Salary_Wage_Rate__c != null) {

                            timecard.Salary_Wage_Value__c = timecard.Hours__c * staff.Salary_Wage_Rate__c;
                        }
                    }
                }
            }
        }
    }

    private static Map<Id, List<Staff__c>> getOpportunityStaff(Set<Id> oppIds) {
        
        // create return collection
        Map<Id, List<Staff__c>> oppStaff = new Map<Id, List<Staff__c>>();

        // iterate over query results to fill collection
        for(Opportunity opp : [SELECT Id, (SELECT Id, Contact__c, Start_Date__c, End_Date__c, Salary_Wage_Rate__c, Benefits_Rate__c FROM Staff__r ORDER BY Contact__c, Start_Date__c NULLS LAST) FROM Opportunity WHERE Id IN :oppIds]) {

            oppStaff.put(opp.Id, opp.Staff__r);
        }

        return oppStaff;
    }

    /*
        Timecards__c record needs to have these fields populated in order
        to set the Salary_Wage_Value__c and Benefits_Value__c
        - Grant__c: we need to retrieve Staff__c, which is related to an Opportunity
        - Contact__c: each person has a rate associated on their Staff__c record
        - Hours__c: a rate times nothing is nothing ☹️
        - Date__c: we use this to find the appropriate Staff__c record (if there are 
            multiple for a given person)
    */
    private static Boolean checkTimecardRequiredFields(Timecards__c timecard) {

        return timecard.Grant__c != null 
                && timecard.Contact__c != null
                && timecard.Hours__c != null 
                && timecard.Date__c != null;
    }

    /*
        return true if:
            if the Staff__c record's Start_Date__c and End_Date__c are null, then there
            are no restrictions on the Timecards__c record's Date__c 

            if the Staff__c record's Start_Date__c is before/same as Timecards__c record's
            Date__c and Staff record's End_Date__c is same/after Timecards__c record's Date__c
    */
    private static Boolean checkTimecardAndStaffDates(Timecards__c timecard, Staff__c staff) {

        return (staff.Start_Date__c == null 
                && staff.End_Date__c == null)
                || (staff.Start_Date__c <= timecard.Date__c
                    && staff.End_Date__c >= timecard.Date__c);
    }
}