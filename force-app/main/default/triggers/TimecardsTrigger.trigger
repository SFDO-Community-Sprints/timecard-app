trigger TimecardsTrigger on Timecards__c (before insert) {

    if(Trigger.isBefore && Trigger.isInsert) {

        TimecardsTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}