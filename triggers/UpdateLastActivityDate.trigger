/*****************************************************************************************************************
Created By: Basavaiah, Gorikapudi*Purpose: Update last activity date (LastActivityDate Field) in Lead and Opportunity with Due Date of Task 
****************************************************************************************************************/
trigger UpdateLastActivityDate on Task (after insert, after update) {

    //Data Set initialization
 list<Id> listWhoIds                         = new list<Id>();
 Set<Id> Ready4LeadUpdate = new Set<Id>();
  Set<Id> Ready4OppUpdate = new Set<Id>();
 map<Id,Date> mapWhoIdsActivityDate          = new map<Id,Date>(); 
 list<Lead> list_UpdateLead = new list<Lead>();
 
 list<Id> listWhatIds                         = new list<Id>(); 
 map<Id,Date> mapWhatIdsActivityDate          = new map<Id,Date>();  
 list<Opportunity> list_UpdateOpportunity     = new list<Opportunity>();
    
    //Construct a collection to hold Lead and Opportunity Ids from Task records 
 for(Task iterating_task : Trigger.new)
  {
    if(iterating_task.WhoId <> null)
     listWhoIds.add(iterating_task.WhoId);
     
      if(iterating_task.WhatId <> null)      
       listWhatIds.add(iterating_task.WhatId);
   }
        
                      
  // Get the list of Tasks related to leadids captured from above   
  Map<ID, Task> taskLeadMap= new Map<ID, Task>([Select t.Who.FirstName, t.Who.LastName, t.Who.Id, t.WhoId, t.Who.Type, t.Status, t.Id, t.Description, t.ActivityDate From Task t
                                              Where t.Who.Type = 'Lead' AND t.Status not in ('Completed','Call Completed') AND t.WhoId in:listWhoIds ORDER BY t.ActivityDate ASC]);
     
     // Get the list of Tasks related to opportunityids captured from above          
     Map<ID, Task> taskOppMap = new Map<ID, Task>([Select t.WhatId, t.ActivityDate From Task t Where t.What.Type = 'Opportunity' AND t.Status not in ('Completed','Call Completed') AND t.WhatId in:listWhatIds ORDER BY t.ActivityDate ASC]);
       
     //Fill the map with leadid and activitydate from the list of Tasks              
  for (Task t1 : taskLeadMap.values()) 
   {    
       if(!Ready4LeadUpdate.contains(t1.WhoId) && t1.ActivityDate >= Date.today())
       {
             mapWhoIdsActivityDate.put(t1.WhoId,t1.ActivityDate);
             Ready4LeadUpdate.add(t1.WhoId);
       }
   }
   
     //Fill the map with opportunityid and activitydate from the list of Tasks                 
     for (Task t1 : taskOppMap.values())   
     {  
     
      if(!Ready4OppUpdate.contains(t1.WhatId) && t1.ActivityDate >= Date.today())
       {  
             mapWhatIdsActivityDate.put(t1.WhatId,t1.ActivityDate); 
             Ready4OppUpdate.add(t1.WhatId);
       }
         
     }

                      
    //Querying for the lead related to the same.                   
  for(Lead leadRec: [SELECT Id,RecordTypeId,Last_Activity_Date__c FROM Lead WHERE Id in:listWhoIds AND RecordTypeId =:Utility_Informatics.lead_Informatics])
   {
     if(mapWhoIdsActivityDate.containsKey(leadRec.Id)) // Check leadid contains in the List of Tasks
       {  
          leadRec.Last_Activity_Date__c = mapWhoIdsActivityDate.get(leadRec.Id);
       }
       else
       {
          leadRec.Last_Activity_Date__c = null;
         
       }
         list_UpdateLead.add(leadRec); 
    
 
   }
   
   //Querying for the opportunity related to the same. 
   for(Opportunity oppRec : [SELECT Id,RecordTypeId,Last_Activity_Date_INF__c FROM Opportunity WHERE Id in:listWhatIds AND RecordTypeId =:Utility_Informatics.opportunity_Informatics])  
   {     
           if(mapWhatIdsActivityDate.containsKey(oppRec.Id))// Check opportunityid contains in the List of Tasks      
           {     
              oppRec.Last_Activity_Date_INF__c = mapWhatIdsActivityDate.get(oppRec.Id);                        
           } 
           else
           {
              oppRec.Last_Activity_Date_INF__c = null;
           }
           list_UpdateOpportunity.add(oppRec);  
                  
      
   } 
   
   if(list_UpdateLead.size() > 0)
   {
    update list_UpdateLead;
   }
   
   if(list_UpdateOpportunity.size() > 0)
   {
    update list_UpdateOpportunity;
   }
  
}