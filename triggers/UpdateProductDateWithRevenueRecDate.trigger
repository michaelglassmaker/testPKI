/****************************************************************************************************************
*Created By: Ang, LayLay
*Purpose: Synchronize Product Date (ServiceDate Field) in Opportunity Line Item with Rev Rec Date of Opportunity
****************************************************************************************************************/
trigger UpdateProductDateWithRevenueRecDate on Opportunity (after insert, after undelete, after update) {
  

    //Construct a collection for Opportunities records from the Trigger 
    Opportunity[] opportunityList;
    opportunityList = Trigger.new;

    //Construct a collection to hold User Ids from Opportunities records 
    list<Id> userList = new list<Id>();
    for (Opportunity opp : opportunityList) {
        userList.add(opp.OwnerId);
    }
    

    //Get the list of Users whose Role Name contains "LST"
    //Map<ID, User> LSTUsers = new Map<ID, User>([select Id from User where Id in :userList AND UserRole.Name like '%LST%']);
        
    // Get the list of Opportunity Ids from the Opportunity collection
    Set<ID> opportunityIds = new Set<ID>();
    
    //Get the Id of Opportunity Recordtype LST FSR
    ID LSTFSRRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('LST FSR').getRecordTypeId();
    
    //Get all the old opportunity values in a map
    Map<Id,Opportunity> oldOpps = new Map<Id,Opportunity>();
    if(Trigger.isUpdate) {
       for (Opportunity ol : Trigger.old) {
            if (ol.RecordtypeId <> LSTFSRRecordTypeID) {
                oldOpps.put(ol.Id,ol);
            }
        } 
    }

    for (Opportunity opp : opportunityList) {
        if (opp.RecordtypeId <> LSTFSRRecordTypeID) {
            opportunityIds.add(opp.Id);
        }
    }
    
    // Get the list of Opportunity Line Items from the Opportunity collection
    Map<ID, OpportunityLineItem> opportunityLineItems = new Map<ID, OpportunityLineItem>([select Id
                                                            ,OpportunityId, ServiceDate, Opportunity_Revenue_Rec_Date__c
                                                            from OpportunityLineItem
                                                            where OpportunityId in :opportunityIds and Is_DAS_Products__c = True]);

    //Update Product Date (ServiceDate field) in Opportunity LineItem
    for (OpportunityLineItem product : opportunityLineItems.values()) {
        Opportunity oldVals = null;
        if(oldOpps.size() > 0)
             oldVals = oldOpps.get(product.opportunityId);
        if(oldVals != null && oldVals.Revenue_Rec_Date__c != product.Opportunity_Revenue_Rec_Date__c)
            product.ServiceDate = product.Opportunity_Revenue_Rec_Date__c;
        if(product.ServiceDate == null)
            product.ServiceDate = product.Opportunity_Revenue_Rec_Date__c;
    }
    update opportunityLineItems.values();

}