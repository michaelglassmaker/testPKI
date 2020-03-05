trigger SVMX_PS_TS_BeforeEventTimesheetTrigger on SVMXC__Timesheet__c (before insert, before update) {
    //Set the Techncian on Timesheet Record
    SVMX_PS_TS_TimesheetUtils timesheetUtils = new SVMX_PS_TS_TimesheetUtils();
    timesheetUtils.handleBeforeTimeSheetTrigger(trigger.new);
}