public with sharing class SMAX_PS_InventoryManager {

    private SMAX_PS_InventoryManager() {
    }

    public static void createStockTransferEvents(List<SVMXC__Stock_Transfer__c> transfers, Map<Id, SVMXC__Stock_Transfer__c> oldMap)
    {
        if (!SMAX_PS_Utility.isActive('Create Stock Transfer Events', 'Create Inventory Platform Events when Stock Transfers are Submitted.'))
            return;

        List<SMAX_PS_Inventory_Event__e> events = new List<SMAX_PS_Inventory_Event__e>();
        for (SVMXC__Stock_Transfer__c stockTransfer : transfers)
        {
            SVMXC__Stock_Transfer__c old = (oldMap == null) ? null : oldMap.get(stockTransfer.Id);
            if (stockTransfer.SMAX_PS_Status__c == 'Submitted' 
                && (old == null || stockTransfer.SMAX_PS_Status__c != old.SMAX_PS_Status__c))
            {
                SMAX_PS_Inventory_Event__e iEvent = new SMAX_PS_Inventory_Event__e();
                iEvent.SMAX_PS_Action__c = 'STOCK_TRANSFER';
                iEvent.SMAX_PS_StockTransferId__c = stockTransfer.Id;
                events.add(iEvent);
            }
        }

        SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_StockTransferId__c', 'SMAX_PS_Action__c');
        //if (!events.isEmpty())
        //{
        //    List<SMAX_PS_ErrorLog__c> logs = new List<SMAX_PS_ErrorLog__c>();
        //    Database.SaveResult[] results = EventBus.publish(events);
        //    for (Integer i = 0; i < results.size(); i++)
        //    {
        //        Database.SaveResult result = results[i];
        //        if (!result.isSuccess())
        //        {
        //            SMAX_PS_Inventory_Event__e iEvent = events[i];
        //            String msg = 'Error publishing Inventory Stock Transfer Event: ' + iEvent.SMAX_PS_StockTransferId__c + ' -- ' + result.getErrors();
        //            System.debug(msg);
        //            logs.add(SMAX_PS_LogUtility.createLog(SMAX_PS_LogUtility.ERROR, msg, 'createStockTransferEvents', null, iEvent.SMAX_PS_StockTransferId__c));
        //        }
        //    }
        //    if (!logs.isEmpty())
        //        insert logs;
        //}
    }
    
    public static void afterUpdateComplete(List<SVMXC__Product_Stock__c> newPStockList, Map<Id, SVMXC__Product_Stock__c> oldPStockMap)
    {
        if (!SMAX_PS_Utility.isActive('Update Product Stock Complete', 'Update Product, Stocked Serial and Delete Product Stock.'))
            return;

        Set<Id> pStockIds = new Set<Id>();
        Set<Id> pdIds = new Set<Id>();
        for (SVMXC__Product_Stock__c ps : newPStockList)
        {
            SVMXC__Product_Stock__c old = (oldPStockMap == null) ? null : oldPStockMap.get(ps.Id);
            if ( old != null && old.SMAX_PS_CompletedTxnNum__c != ps.SMAX_PS_CompletedTxnNum__c )
                pStockIds.add(ps.id);
            if(ps.SVMXC__Product__c != null)
                pdIds.add(ps.SVMXC__Product__c);
            
        }
        if (pStockIds.isEmpty())
            return;

        List<SVMXC__Product_Serial__c> ssList = [SELECT id, name, SMAX_PS_LastTxnNum__c, SVMXC__Product_Stock__c, SVMXC__Active__c 
            FROM SVMXC__Product_Serial__c WHERE SVMXC__Product_Stock__c In :pStockIds];
        Map<id, list<SVMXC__Product_Serial__c>> ssMap = new Map<id, list<SVMXC__Product_Serial__c>>();
        
        //Get the Related Product
        Map<Id, Product2> pdMap = null;
        if (!pdIds.isEmpty())
        {
            pdMap = new Map<Id, Product2>([SELECT Id,   SMAX_PS_Include_in_Download__c
                FROM Product2 WHERE Id IN :pdIds]);
        }
        // Fill in Stocked Serial map
        for (SVMXC__Product_Serial__c ss : ssList) 
        {
            if(!ssMap.containskey(ss.SVMXC__Product_Stock__c)) 
                ssMap.put(ss.SVMXC__Product_Stock__c, new List<SVMXC__Product_Serial__c>());

            ssMap.get(ss.SVMXC__Product_Stock__c).add(ss);
        }

        // Main process
        List<SVMXC__Product_Stock__c> stockToDelete = new List<SVMXC__Product_Stock__c>();
        List<SVMXC__Product_Serial__c> ssUpdateList = new List<SVMXC__Product_Serial__c>();
        List<Product2> pdToUpdate = new List<Product2>();
        for ( SVMXC__Product_Stock__c  ps : newPStockList ) 
        {
            List<SVMXC__Product_Serial__c> listSerial = (ssMap.ContainsKey(ps.Id)) ? ssMap.get(ps.Id) : null;
            
            if (listSerial == null)
            {
                // No Stocked Serials.. should we delete it?
                if (ps.SVMXC__Status__c != 'Available' && ps.SVMXC__Quantity2__c == 0)
                {
                    SVMXC__Product_Stock__c psd = new SVMXC__Product_Stock__c();
                    psd.Id = ps.Id;
                    stockToDelete.add(psd);
                }
            }
            else
            {
                for (SVMXC__Product_Serial__c ss : listSerial) 
                {
                    if (ss.SMAX_PS_LastTxnNum__c != ps.SMAX_PS_CompletedTxnNum__c) {
                        ss.SMAX_PS_Quantity__c = 0;
                        ss.SVMXC__Active__c = false;
                        ssUpdateList.add(ss);
                    } else if (ss.SVMXC__Active__c == false) {
                        ss.SVMXC__Active__c = true;
                        ssUpdateList.add(ss);
                    }
                }
            }
            //Add to Mobile Download Criteria if Available and greater than 0 in quantity
            if (ps.SVMXC__Status__c == 'Available' && ps.SVMXC__Quantity2__c > 0){
                Product2 pd = (pdMap == null) ? null : pdMap.get(ps.SVMXC__Product__c);
                 if(pd != null){
                    pd.SMAX_PS_Include_in_Download__c = TRUE;
                    pdToUpdate.add(pd);
                 }
            }
        } 
        
        // Update Stocked Serial
        if (!ssUpdateList.isEmpty())
            update ssUpdateList;
        if(!pdToUpdate.isEmpty())
            update pdToUpdate;
        if (!stockToDelete.isEmpty())
        {
            //delete stockToDelete;
            Database.DeleteResult[] results = Database.delete(stockToDelete, false);
            for (Integer i = 0; i < results.size(); i++)
            {
                Database.DeleteResult result = results[i];
                if (!result.isSuccess())
                {
                    System.debug('Error deleting Product Stock: ' + result.getId() + ' with Error: ' + result.getErrors());
                }
            }
        }
    }

    public static void copyInventoryCountTechs(List<SMAX_PS_InventoryCount__c> invCountList)
    {
        if (!SMAX_PS_Utility.isActive('Copy Inventory Count Techs', 'Copy Inventory Count Technicians on Create.'))
            return;

        Set<Id> locIds = new Set<Id>();
        for (SMAX_PS_InventoryCount__c invCount : invCountList)
        {
            if (invCount.SMAX_PS_RequestedFrom__c != null)
                locIds.add(invCount.SMAX_PS_RequestedFrom__c);
        }

        if (locIds.isEmpty())
            return;

        Map<Id, SVMXC__Site__c> locMap = new Map<Id, SVMXC__Site__c>([SELECT Id, Name, SVMXC__Service_Engineer__c 
            FROM SVMXC__Site__c WHERE Id IN :locIds]);
        Set<Id> userIds = new Set<Id>();
        for (SMAX_PS_InventoryCount__c invCount : invCountList)
        {
            if (invCount.SMAX_PS_RequestedFrom__c != null)
            {
                SVMXC__Site__c loc = locMap.get(invCount.SMAX_PS_RequestedFrom__c);
                if (loc.SVMXC__Service_Engineer__c != null)
                {
                    invCount.SMAX_PS_Service_Engineer__c = loc.SVMXC__Service_Engineer__c;
                    userIds.add(loc.SVMXC__Service_Engineer__c);
                }
            }
        }

        if (userIds.isEmpty())
            return;

        Map<Id, SVMXC__Service_Group_Members__c> userTechMap = new Map<Id, SVMXC__Service_Group_Members__c>();
        for (SVMXC__Service_Group_Members__c tech : [SELECT Id, Name, SVMXC__Salesforce_User__c
            FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c IN :userIds])
        {
            userTechMap.put(tech.SVMXC__Salesforce_User__c, tech);
        }

        for (SMAX_PS_InventoryCount__c invCount : invCountList)
        {
            if (invCount.SMAX_PS_Service_Engineer__c != null)
            {
                SVMXC__Service_Group_Members__c tech = userTechMap.get(invCount.SMAX_PS_Service_Engineer__c);
                if (tech != null)
                {
                    invCount.SMAX_PS_RequestedTechnician__c = tech.Id;
                }
            }
        }
    }

    public static void createInventoryCountEvents(List<SMAX_PS_InventoryCount__c> invCountList, Map<Id, SMAX_PS_InventoryCount__c> oldMap)
    {
        if (!SMAX_PS_Utility.isActive('Create Inventory Count Events', 'Create Inventory Platform Events when Inventory Counts are Submitted.'))
            return;

        List<SMAX_PS_Inventory_Event__e> events = new List<SMAX_PS_Inventory_Event__e>();
        for (SMAX_PS_InventoryCount__c invCount : invCountList)
        {
            SMAX_PS_InventoryCount__c old = (oldMap == null) ? null : oldMap.get(invCount.Id);
            if (invCount.SMAX_PS_Status__c == 'Confirmed' 
                && (old == null || invCount.SMAX_PS_Status__c != old.SMAX_PS_Status__c))
            {
                SMAX_PS_Inventory_Event__e iEvent = new SMAX_PS_Inventory_Event__e();
                iEvent.SMAX_PS_Action__c = 'COUNT';
                iEvent.SMAX_PS_CountDocumentId__c = invCount.Id;
                events.add(iEvent);
            }
        }

        SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_CountDocumentId__c', 'SMAX_PS_Action__c');
        //if (!events.isEmpty())
        //{
        //    List<SMAX_PS_ErrorLog__c> logs = new List<SMAX_PS_ErrorLog__c>();
        //    Database.SaveResult[] results = EventBus.publish(events);
        //    for (Integer i = 0; i < results.size(); i++)
        //    {
        //        Database.SaveResult result = results[i];
        //        if (!result.isSuccess())
        //        {
        //            SMAX_PS_Inventory_Event__e iEvent = events[i];
        //            String msg = 'Error publishing Inventory Count Confirmed Event: ' + iEvent.SMAX_PS_CountDocumentId__c + ' -- ' + result.getErrors();
        //            System.debug(msg);
        //            logs.add(SMAX_PS_LogUtility.createLog(SMAX_PS_LogUtility.ERROR, msg, 'createInventoryCountEvents', null, iEvent.SMAX_PS_CountDocumentId__c));
        //        }
        //    }
        //    if (!logs.isEmpty())
        //        insert logs;
        //}
    }

    /**
     *  Should be called from the BEFORE INSERT / UPDATE Triggers of SMAX_PS_InventoryCountLine__c
     */
    public static void lookupCountLineCost(List<SMAX_PS_InventoryCountLine__c> lineList, Map<Id, SMAX_PS_InventoryCountLine__c> oldMap)
    {
        if (!SMAX_PS_Utility.isActive('Lookup Count Line Values', 'Create Inventory Platform Events when Inventory Counts are Submitted.'))
            return;

        List<SMAX_PS_InventoryCountLine__c> linesToUpdate = new List<SMAX_PS_InventoryCountLine__c>();
        Set<Id> countIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for (SMAX_PS_InventoryCountLine__c line : lineList)
        {
            SMAX_PS_InventoryCountLine__c old = (oldMap == null) ? null : oldMap.get(line.Id);
            Boolean productChanged = (old != null && line.SMAX_PS_Product__c != old.SMAX_PS_Product__c);
            if (line.SMAX_PS_Product__c != null && (line.SMAX_PS_ProductStock__c == null || productChanged))
            {
                linesToUpdate.add(line);
                countIds.add(line.SMAX_PS_InventoryCount__c);
                productIds.add(line.SMAX_PS_Product__c);
            }
        }

        if (linesToUpdate.isEmpty())
            return;

        // Lookup Inventory Counts.. and their Locations
        Map<Id, SMAX_PS_InventoryCount__c> countMap = new Map<Id, SMAX_PS_InventoryCount__c>(
            [SELECT Id, Name, SMAX_PS_RequestedFrom__c FROM SMAX_PS_InventoryCount__c WHERE Id IN :countIds]);
        Set<Id> locIds = new Set<Id>();
        for (SMAX_PS_InventoryCount__c count : countMap.values())
        {
            locIds.add(count.SMAX_PS_RequestedFrom__c);
        }

        // Lookup all ProductStock with xref of Location and Product
        Map<String, SVMXC__Product_Stock__c> stockMap = new Map<String, SVMXC__Product_Stock__c>();
        for (SVMXC__Product_Stock__c stock : [SELECT Id, Name, SVMXC__Location__c, SVMXC__Product__c, SVMXC__Product_Cost__c
            FROM SVMXC__Product_Stock__c WHERE SVMXC__Status__c = 'Available' 
            AND SVMXC__Location__c IN :locIds AND SVMXC__Product__c IN :productIds])
        {
            String key = stock.SVMXC__Location__c + '-' + stock.SVMXC__Product__c;
            stockMap.put(key, stock);
        }

        // Assign ProductStock to each count line
        for (SMAX_PS_InventoryCountLine__c line : linesToUpdate)
        {
            SMAX_PS_InventoryCount__c count = countMap.get(line.SMAX_PS_InventoryCount__c);
            String key = count.SMAX_PS_RequestedFrom__c + '-' + line.SMAX_PS_Product__c;
            if (stockMap.containsKey(key))
            {
                SVMXC__Product_Stock__c stock = stockMap.get(key);
                line.SMAX_PS_ProductStock__c = stock.Id;
            }
        }
    }
}