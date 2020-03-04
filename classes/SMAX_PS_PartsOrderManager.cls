/*
 *  Apex Class for Parts Order [SVMXC__RMA_Shipment_Order__c] Business Logic.
 *  2017-10-05      Veerendra Moodbidri       Initial creation, for Parts Order Outbound Integration.
 *  1. Create Parts Order Event when Order Status is Submitted to ERP.
 */

public with sharing class SMAX_PS_PartsOrderManager {

    private SMAX_PS_PartsOrderManager() {
    }

    public static void copyRelatedData(List<SVMXC__RMA_Shipment_Order__c> poList)
    {
        if (!SMAX_PS_Utility.isActive('Copy Related Data', 'Copy Account Details to Parts Order.'))
        {
            return;
        }

        // If SVMXC__Destination_Location__c, but no SMAX_PS_Technician__c..
        // Find a Tech referencing the same Loc Id in SVMXC__Inventory_Location__c
        Set<Id> locIds = new Set<Id>();
        // SVMXCFG-541 - WO Ship To Mappings
        Set<Id> woIds = new Set<Id>();
        for (SVMXC__RMA_Shipment_Order__c po : poList)
        {
            if (po.SVMXC__Destination_Location__c != null && po.SMAX_PS_Technician__c == null)
            {
                locIds.add(po.SVMXC__Destination_Location__c);
            }
            if (po.SVMXC__Service_Order__c != null)
            {
                woIds.add(po.SVMXC__Service_Order__c);
            }
        }

        Boolean anyMissingTechs = false;
        if (!locIds.isEmpty())
        {
            Map<Id, SVMXC__Service_Group_Members__c> locTechMap = new Map<Id, SVMXC__Service_Group_Members__c>();
            for (SVMXC__Service_Group_Members__c tech : [SELECT Id, Name, SVMXC__Inventory_Location__c, SVMXC__Inventory_Location__r.SMAX_PS_SalesOrg__c
                FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Inventory_Location__c IN :locIds])
            {
                locTechMap.put(tech.SVMXC__Inventory_Location__c, tech);
            }

            for (SVMXC__RMA_Shipment_Order__c po : poList)
            {
                if (po.SVMXC__Destination_Location__c != null && po.SMAX_PS_Technician__c == null)
                {
                    SVMXC__Service_Group_Members__c tech = locTechMap.get(po.SVMXC__Destination_Location__c);
                    if (tech != null)
                    {
                        po.SMAX_PS_Technician__c = tech.Id;
                        po.SMAX_PS_SalesOrg__c = tech.SVMXC__Inventory_Location__r.SMAX_PS_SalesOrg__c;
                    }
                    else
                    {
                        anyMissingTechs = true;
                    }
                }
            }
        }

        // SVMXCFG-614: Try to auto-fill Technician by Current User..
        if (anyMissingTechs)
        {
            List<SVMXC__Service_Group_Members__c> debriefTechs = 
                [SELECT Id, Name FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c = :UserInfo.getUserId()];
            
            if (debriefTechs.size() > 0 )
            {
                for (SVMXC__RMA_Shipment_Order__c po : poList)
                {
                    if (po.SMAX_PS_Technician__c == null)
                    {
                        po.SMAX_PS_Technician__c = debriefTechs[0].Id;
                    }
                }
            }
        }

        Set<Id> techIds = new Set<Id>();
        for (SVMXC__RMA_Shipment_Order__c po : poList)
        {
            if (po.SMAX_PS_Technician__c != null)
            {
                techIds.add(po.SMAX_PS_Technician__c);
            }
        }

        if (!techIds.isEmpty())
        {
            Map<Id, SVMXC__Service_Group_Members__c> techMap = new Map<Id, SVMXC__Service_Group_Members__c>(
                [SELECT Id, Name, SVMXC__Inventory_Location__c, SVMXC__Inventory_Location__r.SVMXC__Account__c,
                    SVMXC__Inventory_Location__r.SMAX_PS_SalesOrg__c, SMAX_PS_Technician_Manager_Email__c
                FROM SVMXC__Service_Group_Members__c WHERE Id IN :techIds]);
            for (SVMXC__RMA_Shipment_Order__c po : poList)
            {
                if (po.SMAX_PS_Technician__c != null)
                {
                    SVMXC__Service_Group_Members__c tech = techMap.get(po.SMAX_PS_Technician__c);
                    if (tech != null && tech.SVMXC__Inventory_Location__c != null)
                    {
                        if (po.SVMXC__Company__c == null)
                        {
                            po.SVMXC__Company__c = tech.SVMXC__Inventory_Location__r.SVMXC__Account__c;
                        }
                        if (po.SMAX_PS_SalesOrg__c == null)
                        {
                            po.SMAX_PS_SalesOrg__c = tech.SVMXC__Inventory_Location__r.SMAX_PS_SalesOrg__c;
                        }
                    }

                    // SVMXINT-442 -- Retrieve the SalesOrg from the Inventory Location instead of Account Function(s)
                    //if (po.SVMXC__Company__c != null)
                    //    acctIds.add(po.SVMXC__Company__c);

                    // SVMXCFG-914 Fill in SMAX_PS_Technician_Manager_Email__c
                    if (tech != null)
                    {
                        po.SMAX_PS_Technician_Manager_Email__c = tech.SMAX_PS_Technician_Manager_Email__c;
                    }
                }
            }
        }

        // SVMXCFG-614: Last try.. if we didn't find a Tech for the StorageLocation, look it up directly for the SalesOrg
        locIds.clear();
        for (SVMXC__RMA_Shipment_Order__c po : poList)
        {
            if (po.SVMXC__Destination_Location__c != null && po.SMAX_PS_SalesOrg__c == null)
            {
                locIds.add(po.SVMXC__Destination_Location__c);
            }
        }

        if (!locIds.isEmpty())
        {
            Map<Id, SVMXC__Site__c> locMap = new Map<Id, SVMXC__Site__c>([SELECT Id, Name, SMAX_PS_SalesOrg__c
                FROM SVMXC__Site__c WHERE Id IN :locIds]);
            for (SVMXC__RMA_Shipment_Order__c po : poList)
            {
                if (po.SVMXC__Destination_Location__c != null && po.SMAX_PS_SalesOrg__c == null)
                {
                    SVMXC__Site__c loc = locMap.get(po.SVMXC__Destination_Location__c);
                    if (loc != null)
                    {
                        po.SMAX_PS_SalesOrg__c = loc.SMAX_PS_SalesOrg__c;
                    }
                }
            }
        }

        /*
            SVMXCFG-541 - Ship To Mappings
            - Pull from PO.SMAX_PS_ShipTo__c OR po.SVMXC__Company__c INSTEAD.
            Map the (SMAX_PS_Transportation_Zone__c) from the Work Order Ship To Account (SMAX_PS_ShipTo__c) to (SMAX_PS_Transportation_Zone__c) on the Parts Order
            Map the (PKI_SAP_Language__c) from the Work Order Ship To Account (SMAX_PS_ShipTo__c) to the (SMAX_PS_Language__c) on the Parts Order
        */
            if (!woIds.isEmpty())
        {
            Map<Id, SVMXC__Service_Order__c> woMap = new Map<Id, SVMXC__Service_Order__c>([SELECT Id, Name, SMAX_PS_ShipTo__c,
                SMAX_PS_ShipTo__r.SMAX_PS_Transportation_Zone__c, SMAX_PS_ShipTo__r.PKI_SAP_Language__c
                FROM SVMXC__Service_Order__c WHERE Id IN :woIds]);
            for (SVMXC__RMA_Shipment_Order__c po : poList)
            {
                SVMXC__Service_Order__c wo = (po.SVMXC__Service_Order__c != null) ? woMap.get(po.SVMXC__Service_Order__c) : null;
                if (wo != null && wo.SMAX_PS_ShipTo__c != null)
                {
                    po.SMAX_PS_Transportation_Zone__c = wo.SMAX_PS_ShipTo__r.SMAX_PS_Transportation_Zone__c;
                    po.SMAX_PS_Language__c = wo.SMAX_PS_ShipTo__r.PKI_SAP_Language__c;
                }
            }
        }
        
        // SVMXINT-612 map the Transportation Zone and Language from Account if no WO
        Set<Id> acctIds = new Set<Id>();
        for (SVMXC__RMA_Shipment_Order__c po : poList)
        {
            if (po.SVMXC__Service_Order__c == null && po.SVMXC__Company__c != null)
            {
                acctIds.add(po.SVMXC__Company__c);
            }
        }

        if (!acctIds.isEmpty())
        {
            Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, Name, 
                SMAX_PS_Transportation_Zone__c, PKI_SAP_Language__c
                FROM Account WHERE Id IN :acctIds]);
            for (SVMXC__RMA_Shipment_Order__c po : poList)
            {
                if (po.SVMXC__Service_Order__c == null && po.SVMXC__Company__c != null)
                {
                    Account acct = acctMap.get(po.SVMXC__Company__c);
                    if (acct != null)
                    {
                        po.SMAX_PS_Transportation_Zone__c = acct.SMAX_PS_Transportation_Zone__c;
                        po.SMAX_PS_Language__c = acct.PKI_SAP_Language__c;
                    }
                }
            }
        }

        // SVMXINT-630 Lookup Shipment and Delivery Accounts
        Set<String> acctExtIds = new Set<String>();
        for (SVMXC__RMA_Shipment_Order__c po : poList)
        {
            if (po.SVMXC__Company__c == null && po.SMAX_PS_SoldTo_ExtId__c != null)
            {
                acctExtIds.add(po.SMAX_PS_SoldTo_ExtId__c);
            }
            if (po.SMAX_PS_ShipTo__c == null && po.SMAX_PS_ShipTo_ExtId__c != null)
            {
                acctExtIds.add(po.SMAX_PS_ShipTo_ExtId__c);
            }
        }

        if (!acctExtIds.isEmpty())
        {
            Map<String, Account> acctMap = new Map<String, Account>();
            for (Account acct: [SELECT Id, Name, PKI_SAP_Customer_Number__c
                FROM Account WHERE PKI_SAP_Customer_Number__c IN :acctExtIds])
            {
                acctMap.put(acct.PKI_SAP_Customer_Number__c, acct);
            }
            for (SVMXC__RMA_Shipment_Order__c po : poList)
            {
                if (po.SVMXC__Company__c == null && po.SMAX_PS_SoldTo_ExtId__c != null)
                {
                    Account acct = acctMap.get(po.SMAX_PS_SoldTo_ExtId__c);
                    if (acct != null)
                    {
                        po.SVMXC__Company__c = acct.Id;
                    }
                }
                if (po.SMAX_PS_ShipTo__c == null && po.SMAX_PS_ShipTo_ExtId__c != null)
                {
                    Account acct = acctMap.get(po.SMAX_PS_ShipTo_ExtId__c);
                    if (acct != null)
                    {
                        po.SMAX_PS_ShipTo__c = acct.Id;
                    }
                }
            }
        }

    }

    public static void createPartsOrderEvents(List<SVMXC__RMA_Shipment_Order__c> partsOrderNewList, Map<Id, SVMXC__RMA_Shipment_Order__c> partsOrderOldMap)
    {
        if (!SMAX_PS_Utility.isActive('Create Parts Order Events', 'Create Parts Order Platform Events when Order Status is Submitted to ERP.'))
        {
            return;
        }

        List<SMAX_PS_PartsOrder_Event__e> events = new List<SMAX_PS_PartsOrder_Event__e>();
        Map<Id, String> poMap = new Map<Id, String>();

        Map<String, RecordType> recTypeMap = SMAX_PS_Utility.getRecTypeDevNameMap('SVMXC__RMA_Shipment_Order__c');
        RecordType requestRT = recTypeMap.get('Request');
        //RecordType shipmentRT = recTypeMap.get('Shipment');
        //RecordType deliveryRT = recTypeMap.get('Delivery');
        RecordType rmaRT = recTypeMap.get('RMA');
        RecordType loanerRT = recTypeMap.get('Loaner');

        // Collect qualified Parts Order Ids for which Events have to be created
        if (!partsOrderNewList.isEmpty()) {
            for (SVMXC__RMA_Shipment_Order__c po : partsOrderNewList) {
                SVMXC__RMA_Shipment_Order__c old = (partsOrderOldMap == null) ? null : partsOrderOldMap.get(po.Id);
                if ( old == null || old.SVMXC__Order_Status__c != po.SVMXC__Order_Status__c)
                {
                    if (po.SVMXC__Order_Status__c == 'Submitted to ERP')
                    {
                        if (po.RecordTypeId == requestRT.Id)
                        {
                            poMap.put(po.Id, 'REQUEST');
                        }
                        // ITSFDC-509 Send "RMA" Event
                        else if (po.RecordTypeId == rmaRT.Id)
                        {
                            poMap.put(po.Id, 'RMA');
                        }
                        // ITSFDC-510 Send "LOANER" Event
                        else if (po.RecordTypeId == loanerRT.Id)
                        {
                            poMap.put(po.Id, 'LOANER');
                        }
                    }
                    // ITSFDC-510 Send "LOANER_RETURN" Event
                    else if (po.SVMXC__Order_Status__c == 'Return Requested' && po.RecordTypeId == loanerRT.Id)
                    {
                        poMap.put(po.Id, 'LOANER_RETURN');
                    }
                }
            }
        }

        // Publish the Event
        if (!poMap.isEmpty()) {
            for (Id po : poMap.keySet()) {
                SMAX_PS_PartsOrder_Event__e iEvent = new SMAX_PS_PartsOrder_Event__e();
                iEvent.SMAX_PS_Action__c = poMap.get(po);
                iEvent.SMAX_PS_PartsOrderId__c = po;
                events.add(iEvent);
            }
        }

        SMAX_PS_PlatformEventUtility.publishEvents(events, 'SMAX_PS_PartsOrderId__c', 'SMAX_PS_Action__c');
    }

    public static void lookupMasterPartsOrder(List<SVMXC__RMA_Shipment_Order__c> partsOrderNewList, Map<Id, SVMXC__RMA_Shipment_Order__c> oldMap)
    {
        if (!SMAX_PS_Utility.isActive('Lookup Master Parts Order', 'Update Master Parts Order Details.'))
        {
            return;
        }

        // SVMXCFG-550: Status changes based on related parts orders... lookup Record Types
        Map<String, RecordType> recTypeMap = SMAX_PS_Utility.getRecTypeDevNameMap('SVMXC__RMA_Shipment_Order__c');
        RecordType requestRT = recTypeMap.get('Request');
        RecordType shipmentRT = recTypeMap.get('Shipment');
        RecordType deliveryRT = recTypeMap.get('Delivery');

        Set<String> extIds = new Set<String>();
        for (SVMXC__RMA_Shipment_Order__c po : partsOrderNewList)
        {
            SVMXC__RMA_Shipment_Order__c old = (oldMap == null) ? null : oldMap.get(po.Id);
            if (po.SVMXC__Master_Order__c == null && po.SMAX_PS_RelatedExternalId__c != null)
            {
                extIds.add(po.SMAX_PS_RelatedExternalId__c);
            }
            if (po.RecordTypeId == requestRT.Id && po.SMAX_PS_ExternalId__c != null 
                && old != null && old.SMAX_PS_ExternalId__c == null)
            {
                // SVMXCFG-550 : Set Status to "Received by ERP" when SAP Number is populated
                po.SVMXC__Order_Status__c = 'Received by ERP';
            }
        }

        Map<String, SVMXC__RMA_Shipment_Order__c> poMap = new Map<String, SVMXC__RMA_Shipment_Order__c>();
        List<SVMXC__RMA_Shipment_Order__c> poList = new List<SVMXC__RMA_Shipment_Order__c>([SELECT Id, SMAX_PS_ExternalId__c, 
            SVMXC__Service_Order__c, SVMXC__Master_Order__c, OwnerId
            FROM SVMXC__RMA_Shipment_Order__c WHERE SMAX_PS_ExternalId__c IN :extIds]);
        for (SVMXC__RMA_Shipment_Order__c po : poList) {
            poMap.put(po.SMAX_PS_ExternalId__c, po);
        }

        // SVMXCFG-550 : Need to update related Parts Orders sometimes..
        Map<Id, SVMXC__RMA_Shipment_Order__c> relatedUpdates = new Map<Id, SVMXC__RMA_Shipment_Order__c>();

        // Update Master Parts Order Id
        for (SVMXC__RMA_Shipment_Order__c po : partsOrderNewList) 
        {
            if (po.SVMXC__Master_Order__c == null && po.SMAX_PS_RelatedExternalId__c != null)
            {
                SVMXC__RMA_Shipment_Order__c master = poMap.get(po.SMAX_PS_RelatedExternalId__c);
                if (master != null)
                {
                    po.SVMXC__Master_Order__c = (master.SVMXC__Master_Order__c != null) ? master.SVMXC__Master_Order__c : master.Id;
                    po.SVMXC__Service_Order__c = master.SVMXC__Service_Order__c;
                    po.OwnerId = master.OwnerId;

                    SVMXC__RMA_Shipment_Order__c related = new SVMXC__RMA_Shipment_Order__c();
                    related.Id = po.SVMXC__Master_Order__c;
                    if (po.RecordTypeId == shipmentRT.Id) // Received a Shipment.. change request to "Processed"
                    {
                        related.SVMXC__Order_Status__c = 'Processed';
                        relatedUpdates.put(related.Id, related);
                    }
                    else if (po.RecordTypeId == deliveryRT.Id) // Received a Delivery.. change request to "Picked"
                    {
                        related.SVMXC__Order_Status__c = 'Picked';
                        relatedUpdates.put(related.Id, related);
                    }
                }
            }
        }

        if (!relatedUpdates.isEmpty())
        {
            update relatedUpdates.values();
        }
    }

    /**
     *  SVMXINT-573 Parts Orders - Double Submit
     *  Should be called from BEFORE UPDATE
     */
    public static void poStatusChanges(List<SVMXC__RMA_Shipment_Order__c> partsOrders, Map<Id, SVMXC__RMA_Shipment_Order__c> oldMap)
    {
        if (!SMAX_PS_Utility.isActive('Parts Order Status Changes', 'Prevent or Change Parts Order Status changes.'))
        {
            return;
        }

        Map<String, RecordType> recTypeMap = SMAX_PS_Utility.getRecTypeDevNameMap('SVMXC__RMA_Shipment_Order__c');
        RecordType requestRT = recTypeMap.get('Request');
        //RecordType shipmentRT = recTypeMap.get('Shipment');
        //RecordType deliveryRT = recTypeMap.get('Delivery');
        RecordType rmaRT = recTypeMap.get('RMA');
        RecordType loanerRT = recTypeMap.get('Loaner');

        for (SVMXC__RMA_Shipment_Order__c po : partsOrders) {
            SVMXC__RMA_Shipment_Order__c old = (oldMap == null) ? null : oldMap.get(po.Id);
            if ( old != null && po.RecordTypeId == requestRT.Id
                && po.SVMXC__Order_Status__c == 'Submitted to ERP' && old.SVMXC__Order_Status__c == 'Received by ERP')
            {
                // Prevent this change.. should only be allowed to go to "Submitted to ERP" if in "Open" Status
                // SVMXCFG-914: Allow "Submitted to Manager" also
                // SVMXCFG-1006: Changed to ONLY block "Received->Submitted".. other changes should be allowed
                po.SVMXC__Order_Status__c = old.SVMXC__Order_Status__c;
            }

            // ITSFDC-509 Advance the Order Status as SAP RMA Documents are received
            if ( old != null && po.RecordTypeId == rmaRT.Id)
            {
                if (po.SMAX_PS_ExternalId__c != null && po.SMAX_PS_ExternalId__c != old.SMAX_PS_ExternalId__c)
                {
                    po.SVMXC__Order_Status__c = 'Return Requested';
                }
                if (po.BD_SAP_Delivery_Number__c != null && po.BD_SAP_Delivery_Number__c != old.BD_SAP_Delivery_Number__c)
                {
                    po.SVMXC__Order_Status__c = 'Received';
                }
                if (po.BD_SAP_Return_Number__c != null && po.BD_SAP_Return_Number__c != old.BD_SAP_Return_Number__c)
                {
                    po.SVMXC__Order_Status__c = 'Shipment Requested';
                }
                if (po.BD_SAP_Return_Delivery_Number__c != null && po.BD_SAP_Return_Delivery_Number__c != old.BD_SAP_Return_Delivery_Number__c)
                {
                    po.SVMXC__Order_Status__c = 'Issued from Warehouse';
                }
            }
            // ITSFDC-510 Advance the Order Status as SAP Loaner Documents are received
            if ( old != null && po.RecordTypeId == loanerRT.Id)
            {
                if (po.SMAX_PS_ExternalId__c != null && po.SMAX_PS_ExternalId__c != old.SMAX_PS_ExternalId__c)
                {
                    po.SVMXC__Order_Status__c = 'Loan Requested';
                }
                if (po.BD_SAP_Delivery_Number__c != null && po.BD_SAP_Delivery_Number__c != old.BD_SAP_Delivery_Number__c)
                {
                    po.SVMXC__Order_Status__c = 'On Loan';
                }
                if (po.BD_SAP_Return_Number__c != null && po.BD_SAP_Return_Number__c != old.BD_SAP_Return_Number__c)
                {
                    po.SVMXC__Order_Status__c = 'Loaner Return';
                }
                if (po.BD_SAP_Return_Delivery_Number__c != null && po.BD_SAP_Return_Delivery_Number__c != old.BD_SAP_Return_Delivery_Number__c)
                {
                    po.SVMXC__Order_Status__c = 'Returned';
                }
            }
        }
    }

    // SVMXCFG-899 Enforce Parts Order Field Sizes
    public static void trimValues(List<SVMXC__RMA_Shipment_Order__c> partsOrders, Map<Id, SVMXC__RMA_Shipment_Order__c> oldMap)
    {
        if (!SMAX_PS_Utility.isActive('Parts Order Trim Values', 'Trim values in Parts Order fields to ensure they will not error in SAP.'))
        {
            return;
        }

        Id poRequestRecordTypeId = SMAX_PS_Utility.getRecordType('SVMXC__RMA_Shipment_Order__c', 'Request').Id;

        for (SVMXC__RMA_Shipment_Order__c po : partsOrders) {
            SVMXC__RMA_Shipment_Order__c old = (oldMap == null) ? null : oldMap.get(po.Id);
            if (po.RecordTypeId == poRequestRecordTypeId)
            {
                if (po.SVMXC__Destination_City__c != null)
                {
                    po.SVMXC__Destination_City__c = po.SVMXC__Destination_City__c.left(40);
                }
                if (po.SVMXC__Destination_Zip__c != null)
                {
                    po.SVMXC__Destination_Zip__c = po.SVMXC__Destination_Zip__c.left(10);
                }
            }
        }
    }

    // ITSFDC-509 Assign the WO to the Depot Work Center Technician
//  public static void assignToDepot(List<SVMXC__RMA_Shipment_Order__c> partsOrders, Map<Id, SVMXC__RMA_Shipment_Order__c> oldMap)
//  {
//      if (!SMAX_PS_Utility.isActive('Parts Order Assign To Depot', 'On RMA PArts Orders, assign the Work Order to the Depot Work Center when it is received.'))
//      {
//          return;
//      }
//
//      Map<String, RecordType> recTypeMap = SMAX_PS_Utility.getRecTypeDevNameMap('SVMXC__RMA_Shipment_Order__c');
//      RecordType rmaRT = recTypeMap.get('RMA');
//
//      // NOTE: We might need to change this logic to use BOTH WorkCenter + Plant!
//
//      Map<Id, String> woWorkCenterMap = new Map<Id, String>();
//      for (SVMXC__RMA_Shipment_Order__c po : partsOrders)
//      {
//          SVMXC__RMA_Shipment_Order__c old = (oldMap == null) ? null : oldMap.get(po.Id);
//          if (po.RecordTypeId == rmaRT.Id && po.SVMXC__RMA_Type__c == 'Instrument' && po.SVMXC__Service_Order__c != null)
//          {
//              if (po.BD_Depot_Work_Center__c != null && po.BD_Depot_Work_Center__c != old.BD_Depot_Work_Center__c)
//              {
//                  // Find Technician with matching value, and set the “Assigned Technician” on the WO
//                  Id woId = po.SVMXC__Service_Order__c;
//                  woWorkCenterMap.put(woId, po.BD_Depot_Work_Center__c);
//              }
//          }
//      }
//
//      if (woWorkCenterMap.isEmpty())
//      {
//          return;
//      }
//
//      // Lookup "Work Center" Technicians...
//      Set<String> workCenters = new Set<String>(woWorkCenterMap.values());
//      Map<String, SVMXC__Service_Group_Members__c> workCenterMap = new Map<String, SVMXC__Service_Group_Members__c>();
//      List<SVMXC__Service_Group_Members__c> techs = [SELECT Id, Name, SMAX_PS_Work_Center__c, BD_Depot_Queue_Id__c
//          FROM SVMXC__Service_Group_Members__c WHERE SMAX_PS_Work_Center__c IN :workCenters];
//      for (SVMXC__Service_Group_Members__c tech : techs)
//      {
//          workCenterMap.put(tech.SMAX_PS_Work_Center__c, tech);
//      }
//
//
//      List<SVMXC__Service_Order__c> woList = new List<SVMXC__Service_Order__c>();
//      for (Id woId : woWorkCenterMap.keySet())
//      {
//          String workCenter = woWorkCenterMap.get(woId);
//          SVMXC__Service_Group_Members__c tech = workCenterMap.get(workCenter);
//          if (tech != null)
//          {
//              SVMXC__Service_Order__c wo = new SVMXC__Service_Order__c();
//              wo.Id = woId;
//              wo.SVMXC__Group_Member__c = tech.Id;
//              woList.add(wo);
//          }
//      }
//
//      if (!woList.isEmpty())
//      {
//          update woList;
//      }
//  }

    // ITSFDC-510 Lookup Loaner Equipment (BEFORE INSERT/UPDATE)
    public static void lookupLoanerEquipment(List<SVMXC__RMA_Shipment_Order__c> partsOrders, Map<Id, SVMXC__RMA_Shipment_Order__c> oldMap)
    {
        if (!SMAX_PS_Utility.isActive('Parts Order Loaner Lookup', 'On Loaner Parts Orders, lookup the loaner Equipment by SAP Equipment ID.'))
        {
            return;
        }

        Map<String, RecordType> recTypeMap = SMAX_PS_Utility.getRecTypeDevNameMap('SVMXC__RMA_Shipment_Order__c');
        //RecordType requestRT = recTypeMap.get('Request');
        //RecordType shipmentRT = recTypeMap.get('Shipment');
        //RecordType deliveryRT = recTypeMap.get('Delivery');
        //RecordType rmaRT = recTypeMap.get('RMA');
        RecordType loanerRT = recTypeMap.get('Loaner');

        List<SVMXC__RMA_Shipment_Order__c> loaners = new List<SVMXC__RMA_Shipment_Order__c>();
        Set<String> equipmentIds = new Set<String>();
        for (SVMXC__RMA_Shipment_Order__c po : partsOrders)
        {
            SVMXC__RMA_Shipment_Order__c old = (oldMap == null) ? null : oldMap.get(po.Id);
            if (po.RecordTypeId == loanerRT.Id && po.BD_Loaner_Equipment_External_Id__c != null && po.BD_Loaner_Equipment__c == null)
            {
                loaners.add(po);
                equipmentIds.add(po.BD_Loaner_Equipment_External_Id__c);
            }
        }

        if (loaners.isEmpty())
        {
            return;
        }

        // Lookup "Equipment"...
        Map<String, SVMXC__Installed_Product__c> equipmentMap = new Map<String, SVMXC__Installed_Product__c>();
        for (SVMXC__Installed_Product__c ip : [SELECT Id, Name, SVMX_PS_External_ID__c
            FROM SVMXC__Installed_Product__c WHERE SVMX_PS_External_ID__c IN :equipmentIds])
        {
            equipmentMap.put(ip.SVMX_PS_External_ID__c, ip);
        }

        for (SVMXC__RMA_Shipment_Order__c loaner : loaners)
        {
            SVMXC__Installed_Product__c ip = equipmentMap.get(loaner.BD_Loaner_Equipment_External_Id__c);
            if (ip != null)
            {
                loaner.BD_Loaner_Equipment__c = ip.Id;
            }
        }
    }

}