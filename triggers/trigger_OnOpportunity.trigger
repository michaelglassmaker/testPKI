/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Title           : trigger_OnOpportunity
Author          : Lister Technologies
Description     : This is a trigger on Opportunity which calls out handler classes.
Test Class      : 
Created on      : May 12th 2017
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/***********************************************************************************************************/
/*|S.N0|-----------Description---------|--Modified On--|--Modified By--|--Tag--|-----------Test Class-------|
/***********************************************************************************************************/
/*|    |                               |               |               |       |                            |
/*|    |                               |               |               |       |                            |
/*|    |                               |               |               |       |                            |
/***********************************************************************************************************/
trigger trigger_OnOpportunity on Opportunity (before update, after insert, after update) {
    PDG_Opp_LDR_Conversion OppLDRCon = new PDG_Opp_LDR_Conversion(trigger.new,trigger.oldmap);
    
    if(trigger.isInsert){
        //For ANNUITAS Development//
        if(trigger.isAfter){
            OppLDRCon.LDR_Owner_Converison();
            OppLDRCon.CheckContactRoleAndSAI();
                }
        //END
    }
    if(trigger.isUpdate){
        Handler_PopulateRequestStatusOnTask handler1 = new Handler_PopulateRequestStatusOnTask(trigger.new,trigger.oldmap,trigger.newmap);
        handler1.updateTask();
        
        system.debug('Line 29');
        //For ANNUITAS Development//
        if(trigger.isBefore){
            OppLDRCon.LDR_Owner_Change();
            handler1.updateLastModified(Trigger.new);
        }
        if(trigger.isAfter){
           OppLDRCon.CheckContactRoleAndSAI();
         
        }
        //END
    }
    
    
}