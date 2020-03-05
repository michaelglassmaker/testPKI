trigger SMAX_PS_PartsOrderEvent on SMAX_PS_PartsOrder_Event__e (after insert) {
    List<SMAX_PS_Platform_Event_Log__c> logs = new List<SMAX_PS_Platform_Event_Log__c>();
    for (SMAX_PS_PartsOrder_Event__e evt : trigger.new)
    {
        Id poId = evt.SMAX_PS_PartsOrderId__c;
        SMAX_PS_Platform_Event_Log__c log = SMAX_PS_PlatformEventUtility.createEventLog(evt, poId, evt.SMAX_PS_Action__c);
        System.debug('Created Platform Event Log: ' + log);
        logs.add(log);
    }
    insert logs;
}