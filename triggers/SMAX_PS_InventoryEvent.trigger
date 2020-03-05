trigger SMAX_PS_InventoryEvent on SMAX_PS_Inventory_Event__e (after insert) {
    List<SMAX_PS_Platform_Event_Log__c> logs = new List<SMAX_PS_Platform_Event_Log__c>();
    for (SMAX_PS_Inventory_Event__e evt : trigger.new)
    {
        Id elemId = null;
        if (evt.SMAX_PS_StockTransferId__c != null)
            elemId = evt.SMAX_PS_StockTransferId__c;
        else if (evt.SMAX_PS_CountDocumentId__c != null)
            elemId = evt.SMAX_PS_CountDocumentId__c;
            
        SMAX_PS_Platform_Event_Log__c log = SMAX_PS_PlatformEventUtility.createEventLog(evt, elemId, evt.SMAX_PS_Action__c);
        System.debug('Created Platform Event Log: ' + log);
        logs.add(log);
    }
    insert logs;
}