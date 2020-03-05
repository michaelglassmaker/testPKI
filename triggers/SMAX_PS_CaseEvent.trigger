trigger SMAX_PS_CaseEvent on Case_Event__e (after insert) {
    List<SMAX_PS_Platform_Event_Log__c> logs = new List<SMAX_PS_Platform_Event_Log__c>();
    for (Case_Event__e evt : trigger.new)
    {
        Id cId = evt.CaseId__c;
        String action = '?????';
        SMAX_PS_Platform_Event_Log__c log = SMAX_PS_PlatformEventUtility.createEventLog(evt, cId, action);
        System.debug('Created Platform Event Log: ' + log);
        logs.add(log);
    }
    insert logs;
}