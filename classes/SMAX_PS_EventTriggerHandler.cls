public with sharing class SMAX_PS_EventTriggerHandler implements SMAX_PS_Utility.ITriggerHandler{
    public SMAX_PS_EventTriggerHandler() {
        
    }
    public void beforeInsert() 
    {
        List<Event> newList = Trigger.new;

        SMAX_PS_AutoAssignment.syncEventFields(newList);

    }

    public void afterInsert()
    {
        List<Event> newList = Trigger.new;

        //Timesheet Functionality
        SVMX_PS_TS_TimesheetUtils timesheetUtils = new SVMX_PS_TS_TimesheetUtils();
        timesheetUtils.handleEventsFromSalesforceEvents(newList, null, null, true, false, false);

        SMAX_PS_AutoAssignment.schedulingConfirm(newList, null);
    }

    public void beforeUpdate() 
    {
        List<Event> newList = Trigger.new;
        Map<Id, Event> oldMap = (Map<Id, Event>) Trigger.oldMap;

        // SVMXCFG-820 Event Trigger Code Update and Batch Class to update event records
        // Rolling back the "updates" - Frank 20181106
        //SMAX_PS_AutoAssignment.syncEventFields(newList);
    }

    public void afterUpdate()
    {
        List<Event> newList = Trigger.new;
        Map<Id, Event> oldMap = (Map<Id, Event>) Trigger.oldMap;
        List<Event> oldList = Trigger.old;

        //Timesheet Functionality
        SVMX_PS_TS_TimesheetUtils timesheetUtils = new SVMX_PS_TS_TimesheetUtils();
        timesheetUtils.handleEventsFromSalesforceEvents(newList, oldMap, oldList, false, true, false);

        SMAX_PS_AutoAssignment.schedulingConfirm(newList, oldMap);
        

    }

    public void beforeDelete() 
    {
        List<Event> newList = Trigger.new;
        Map<Id, Event> oldMap = (Map<Id, Event>) Trigger.oldMap;
        List<Event> oldList = Trigger.old;

        //Timesheet Functionality
        SVMX_PS_TS_TimesheetUtils timesheetUtils = new SVMX_PS_TS_TimesheetUtils();
        timesheetUtils.handleEventsFromSalesforceEvents(newList, oldMap, oldList, false, false, true);
    }
    public void afterDelete() 
    {
        List<Event> oldList = Trigger.old;
    }

    public void afterUndelete() 
    {
        List<Event> newList = Trigger.new;
    }   
}