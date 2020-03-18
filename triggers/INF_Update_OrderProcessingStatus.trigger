/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Change History

**************************************************************************************************************************************
ModifiedBy          Date                 Requested By         Description                                          Tag
**************************************************************************************************************************************
Ramyaa              14/08/18              PKI               To overcome Apex CPU time limit exceeded error
                                                            and prevent update on opportunity                      <T1>
--------------------------------------------------------------------------------------------------------------------------------------*/

//trigger INF_Update_OrderProcessingStatus on Opportunity (after update) { //commented for <T1>
  trigger INF_Update_OrderProcessingStatus on Opportunity (before update) { //<T1>
    
    Set<Id> SetOfOppIds = new Set<Id>();
   // List<Opportunity> listOfOpp = new List<Opportunity>(); //commented for <T1>
    Map<Id,List<OpportunityLineItem>> mapOfOppIdToOppLineItems = new Map<Id,List<OpportunityLineItem>>();
    
    for(Opportunity opp : Trigger.New){
        if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics && opp.StageName == 'Stage 6 - Implement (Closed)' && (Trigger.oldMap.get(opp.Id).StageName!=Trigger.newMap.get(opp.Id).StageName)){
           SetOfOppIds.add(opp.Id);
        }
            
    }

    for(Opportunity op :[Select o.Id,o.Order_Processing_Status_INF__c,o.GP_OrderNum_INF__c,
                          (Select PricebookEntry.Product2.License_Type_INF__c,PricebookEntry.Product2.Product_Type_INF__c,PricebookEntry.Product2.Name,PricebookEntry.Product2.product_line__c From OpportunityLineItems
                           WHERE (PricebookEntry.Product2.License_Type_INF__c ='Services' OR PricebookEntry.Product2.Product_Type_INF__c ='Services'OR PricebookEntry.Product2.Name='OneSource LABIT' OR PricebookEntry.Product2.product_line__c ='OMV'))                                    
                        From Opportunity o where Id IN:SetOfOppIds]){
            
           if(op.OpportunityLineItems.size()>0)
           { 
                  
            for(OpportunityLineItem Oppl:op.OpportunityLineItems)
            {
              if((Oppl.PricebookEntry.Product2.Name == 'OneSource LABIT' || Oppl.PricebookEntry.Product2.product_line__c == 'OMV') && !mapOfOppIdToOppLineItems.containsKey(op.Id))
                    {
                    SYSTEM.DEBUG('INSIDE OMV CONDITION');
                         Trigger.newMap.get(op.Id).Order_Processing_Status_INF__c = 'Submitted'; //<T1>
                         Trigger.newMap.get(op.Id).GP_OrderNum_INF__c = '#';  //<T1>
                        // listOfOpp.add(op);  //commented for <T1>
                         mapOfOppIdToOppLineItems.put(op.Id,op.OpportunityLineItems);
                     }
                else if((Oppl.PricebookEntry.Product2.Product_Type_INF__c == 'Services' || Oppl.PricebookEntry.Product2.License_Type_INF__c == 'Services') && !mapOfOppIdToOppLineItems.containsKey(op.Id))
                    {
                         //op.Order_Processing_Status_INF__c = 'Revenue Review Required'; //commented for <T1>
                         Trigger.newMap.get(op.Id).Order_Processing_Status_INF__c = 'Revenue Review Required'; //<T1>
                        // listOfOpp.add(op);   //commented for <T1>
                         mapOfOppIdToOppLineItems.put(op.Id,op.OpportunityLineItems); 
                    }  
             } 
             
                
           }    
           
             
      } 
     // if(listOfOpp.size()>0) //commented for <T1>
     //   update listOfOpp;    //commented for <T1>
    }