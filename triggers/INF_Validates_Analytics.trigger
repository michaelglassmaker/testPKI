trigger INF_Validates_Analytics on Opportunity (after Update) {

    Set<Id> SetOfOppIds = new Set<Id>();
  List<Opportunity> listOfOpp = new List<Opportunity>();
  List<Opportunity> listOfOppUpdate = new List<Opportunity>();
  Map<Id,List<OpportunityLineItem>> mapOfOppIdToOppLineItems = new Map<Id,List<OpportunityLineItem>>();

    for(Opportunity opp : Trigger.New)
    {
        if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics  && (opp.StageName == 'Stage 1 - Create/Plan' || opp.StageName == 'Stage 2 - Qualify' || opp.StageName == 'Stage 3 - Develop' || opp.StageName == 'Stage 4 - Prove' || opp.StageName == 'Stage 5 - Negotiation' || opp.StageName == 'Stage 6 - Implement (Closed)') && (Trigger.oldMap.get(opp.Id).StageName!=Trigger.newMap.get(opp.Id).StageName))
        {
           SetOfOppIds.add(opp.Id);
        }
    }
List<Opportunity> Optylist = [Select Id,INF_Analytics_AVS__c,
                          (Select Product2.Family,OpportunityId,Product2.INF_Split__c From OpportunityLineItems
                           WHERE  isDeleted = false AND Product2.INF_Split__c='Yes' )                                    
                        From Opportunity o where Id IN:SetOfOppIds]; 
      if(Optylist.size()>0){
    for(Opportunity op : Optylist)
     {  
        if(op.OpportunityLineItems.size()>0)
         {  
           if(!mapOfOppIdToOppLineItems.containsKey(op.Id))
             {
                 mapOfOppIdToOppLineItems.put(op.Id,op.OpportunityLineItems);
                 listOfOpp.add(op);
             } 
         } 
        else if(!mapOfOppIdToOppLineItems.containsKey(op.Id))
          {
                         op.INF_Analytics_AVS__c = NULL;
                         listOfOppUpdate.add(op);   
                         mapOfOppIdToOppLineItems.put(op.Id,op.OpportunityLineItems); 
           }
        }
        }
    if(listOfOpp.size()>0)
     {
        for (Opportunity newOpp: listOfOpp) 
        {
           if (newOpp.INF_Analytics_AVS__c==null) 
            {
               System.debug('********** Line item output Opp value *******'+ newOpp.INF_Analytics_AVS__c);
               Trigger.newMap.get(newOpp.Id).AddError('Please Enter Research Analytics Value');
            }
       }
     }
    if(listOfOppUpdate.size()>0)
    {
       for (Opportunity upOpp: listOfOppUpdate) 
       {
      System.debug('**********Update *******'+ upOpp.INF_Analytics_AVS__c);
              
   }
   update listOfOppUpdate;
  }
 }