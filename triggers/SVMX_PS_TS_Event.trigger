trigger SVMX_PS_TS_Event on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SMAX_PS_Utility.executeHandler(new SMAX_PS_EventTriggerHandler());

	//old pre-TriggerHandler
    //Timesheet Functionality
    //SVMX_PS_TS_TimesheetUtils timesheetUtils = new SVMX_PS_TS_TimesheetUtils();
    //timesheetUtils.handleEventsFromSalesforceEvents(trigger.new, trigger.oldMap, trigger.old, trigger.isInsert, trigger.isUpdate, trigger.isDelete);

    //if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate))
	//{
	//    SMAX_PS_AutoAssignment.schedulingConfirm(trigger.new, trigger.oldMap);
	//}

}