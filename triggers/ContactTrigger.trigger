trigger ContactTrigger on Contact (before insert,after insert,before update,after update) {
    multi_Interaction_logic mt = new multi_Interaction_logic(Trigger.new, Trigger.oldMap);
    PDG_Routing_Class pdg = new PDG_Routing_Class(Trigger.new, Trigger.oldMap);

    if(Trigger.isInsert){
        if(Trigger.isBefore){     
            // For ANNUITAS Development //
            for(Contact a : Trigger.new){
                a.Did_Trigger_Run__c = 'Yes (Insert)';
            }            
            //pdg.Contact_Records(); 
            //mt.Contact_Records();
            // *END* //    
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
       pdg.Contact_Records(); 
    }
 
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            // For ANNUITAS Development //
            for(Contact a : Trigger.new){
                a.Did_Trigger_Run__c = 'Test';
            }  
            mt.Contact_Records();
            pdg.Contact_Records(); 
            // *END* //            
        }
    }
    
  
}