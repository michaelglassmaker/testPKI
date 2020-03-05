trigger SMAX_PS_ServiceContractEvent on SMAX_PS_ServiceContract_Event__e (after insert) {
    if (Test.isRunningTest())
        SMAX_PS_Utility.saveTestEvents('SMAX_PS_ServiceContract_Event__e', trigger.new);

    List<SMAX_PS_Platform_Event_Log__c> logs = new List<SMAX_PS_Platform_Event_Log__c>();
    for (SMAX_PS_ServiceContract_Event__e evt : trigger.new)
    {
        Id scId = evt.SMAX_PS_ServiceContractId__c;
        SMAX_PS_Platform_Event_Log__c log = SMAX_PS_PlatformEventUtility.createEventLog(evt, scId, evt.SMAX_PS_Action__c);
        System.debug('Created Platform Event Log: ' + log);
        logs.add(log);
    }
    insert logs;
}