trigger SVMX_PS_TS_WorkDetail on SVMXC__Service_Order_Line__c (after insert, after update, before delete) {
    //Timesheet Functionality
    SVMX_PS_TS_TimesheetUtils timesheetUtils = new SVMX_PS_TS_TimesheetUtils();
    timesheetUtils.handleEventsFromWorkDetails(trigger.new, trigger.oldMap, trigger.old, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
}