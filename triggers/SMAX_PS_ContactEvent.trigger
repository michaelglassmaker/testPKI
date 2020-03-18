trigger SMAX_PS_ContactEvent on SMAX_PS_Contact_Event__e (after insert) {
    if (Test.isRunningTest())
        SMAX_PS_Utility.saveTestEvents('SMAX_PS_Contact_Event__e', trigger.new);

    List<SMAX_PS_Platform_Event_Log__c> logs = new List<SMAX_PS_Platform_Event_Log__c>();
    for (SMAX_PS_Contact_Event__e evt : trigger.new)
    {
        Id cId = evt.SMAX_PS_SFDC_Contact_Id__c;
        String action = (evt.SMAX_PS_SAP_Contact_Id__c == null) ? 'CREATE' : 'UPDATE';
        SMAX_PS_Platform_Event_Log__c log = SMAX_PS_PlatformEventUtility.createEventLog(evt, cId, action);
        System.debug('Created Platform Event Log: ' + log);
        logs.add(log);
    }
    insert logs;
}