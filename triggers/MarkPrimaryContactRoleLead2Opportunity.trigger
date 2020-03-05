/***********************************************************
*Created By: Lister technologies
*Purpose: For Informatics,to make the Contact created as Primary which is included as Contact Role in Opportunity while lead conversion. 
************************************************************/
trigger MarkPrimaryContactRoleLead2Opportunity on Lead (before insert, after insert, after update) {
   
    //Concatenating the lead field
    if(Trigger.isInsert && Trigger.isBefore){
        //looping and contacting the field
        for(Lead iterating_lead : Trigger.new){
            if(iterating_lead.RecordTypeID == Utility_Informatics.lead_Informatics){
                iterating_lead.INF_Lead_Assignment_Field__c = '';
                if(iterating_lead.Topic_INF__c != null)
                    iterating_lead.INF_Lead_Assignment_Field__c = iterating_lead.Topic_INF__c + ' - ';
                if(iterating_lead.BusinessLine_INF__c <> null)
                    iterating_lead.INF_Lead_Assignment_Field__c +=  iterating_lead.BusinessLine_INF__c + ' - ';
                if(iterating_lead.Product_Interest_INF__c <> null)
                    iterating_lead.INF_Lead_Assignment_Field__c += iterating_lead.Product_Interest_INF__c + ' - ';
                if(iterating_lead.Product_Family_INF__c <> null)
                    iterating_lead.INF_Lead_Assignment_Field__c += iterating_lead.Product_Family_INF__c;
            }
        }
    }
    //Assignment rule forcing using APEX
    if(Trigger.isInsert && Trigger.isAfter){
        
         
        list<Id> listOfLeadsToBeUpdated = new list<Id>();
        //Looping and checking if the leads are informatics record type
        for(Lead iterating_lead : Trigger.new){
        
            if(iterating_lead.RecordTypeID == Utility_Informatics.lead_Informatics && !iterating_lead.Do_not_Run_Assignment_Rules_INF__c){ //Only informatics record type and if the assignment rule checkbox is set to true
                  listOfLeadsToBeUpdated .add(iterating_lead.Id);           
                //iterating_lead.setOptions(dmo);  
            }
        
        }
            
        if(!listOfLeadsToBeUpdated.isEmpty())
            Utility_Informatics.assignLeads_Informatics(listOfLeadsToBeUpdated );
        
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        System.debug('Is Updated Lead');
        Map<Id,Id> mapOfOppIdToContactId = new Map<Id,Id>();
        List<OpportunityContactRole> listOfConvertedOppContactRoletoUpdate = new List<OpportunityContactRole>();
        
        // Logic to collect only the converted Lead records on day into a map of Opportunity Id to Contact Id.
        for(Lead l:Trigger.new)
        {
            if(l.RecordTypeId == Utility_Informatics.lead_Informatics && l.IsConverted && l.ConvertedDate == System.today() && l.ConvertedOpportunityId!=NULL && l.ConvertedContactId!=NULL)
            {
                mapOfOppIdToContactId.put(l.ConvertedOpportunityId,l.ConvertedContactId);
            }
        }
        //Following logic will execute only when the map is not empty
        if(mapOfOppIdToContactId.size() > 0)
        {
            /*
                Querying the Contact Role records under Opportunity after Lead conversion and if the Contact Id in the Contact Role record matches with the Contact Id
                in the map for the same Opportunity Id, then the Contact Role will be marked as Primary.
            */
             for(OpportunityContactRole oCRcon:[Select OpportunityId, IsPrimary, Id, ContactId From OpportunityContactRole where OpportunityId IN:mapOfOppIdToContactId.keySet()])                                  
            {
                if(oCRcon.ContactId == mapOfOppIdToContactId.get(oCRcon.OpportunityId))
                {
                    oCRcon.IsPrimary = true;
                    oCRcon.Role      = 'Decision Maker';
                    listOfConvertedOppContactRoletoUpdate.add(oCRcon);
                }
            }
            
            //DML Operation to update the existing Contact Role record under opportunity with Primary Contacts
            try{
                update listOfConvertedOppContactRoletoUpdate;
            }catch(DMLException e)
            {
                //System.debug('>>> Error Updating OpportunityContactRole:'+e.getStackTraceString());
            }
        }
    }

}