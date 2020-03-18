trigger LeadTrigger on Lead (before insert,after insert,before update,after update) {
    Lead_Methods LM = new Lead_Methods(Trigger.oldMap,Trigger.old,Trigger.newMap,Trigger.new);
    LM.LeadMethods(Trigger.oldMap,Trigger.newMap,Trigger.old,Trigger.new,Trigger.isInsert,Trigger.IsBefore,Trigger.isAfter,Trigger.isUpdate);
    //For ANNUITAS Development//
    multi_Interaction_logic mt = new multi_Interaction_logic(Trigger.new, Trigger.oldMap);
	PDG_Routing_Class pdg = new PDG_Routing_Class(Trigger.new, Trigger.oldMap);
    
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            System.debug('Inside isInsert.. Before..');
            //For ANNUITAS Development//
            for(Lead a : Trigger.new){
                a.Did_Trigger_Run__c = 'Yes (Insert)';
            }    	    
            pdg.Lead_Records(); 
        	//*END*// 
        	
            //For ANNUITAS Development//
            mt.Lead_Records();
            
            //Concatenate Informatics fields
            LM.INFConcatFields();
        	//Added to assign eloqua owner as lead owner during lead creation
            LM.LeadEloquaAssign();
            //concatenate values
            LM.LeadTopic();
        }
        if(Trigger.isAfter){
        	System.debug('Inside isInsert.. After..'); 
        
          }        
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            //For ANNUITAS Development//
            mt.Lead_Records();
    	    pdg.Lead_Records();
            for(Lead a : Trigger.new){
                a.Did_Trigger_Run__c = 'Yes (Update)';
            }        
        }
        if(Trigger.isAfter){
            //Applies only for Informatics records
            LM.MarkPrimaryContactRoleLead2Opportunity();
            //Re-run Lead assignment rules
            LM.runLeadAssignRule();
        }
    }
}