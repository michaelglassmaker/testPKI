trigger ResetCloneOpportunity on Opportunity (before Insert) {
   if(trigger.isBefore && trigger.IsInsert){
    Id PKIRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PKI SPI Sales Process').getRecordTypeId();
    Id EMEART = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Dx EMEA Record Type').getRecordTypeId();
    Id Infor= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Informatics').getRecordTypeId();
    Id DXRecord= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Dx Record Type').getRecordTypeId();
    Profile prof = [Select Id, Name from Profile where Id=: UserInfo.getProfileId() Limit 1];
       for(Opportunity op: Trigger.new){
           if(op.IsClone()){                    
                if(op.recordTypeId==PKIRT || op.recordTypeId==EMEART || (op.recordTypeId==Infor && OppResetControl.DoNotReset == false)){
                op.ForecastCategoryName='Pipeline';
                   op.StageName='Stage 1 - Create/Plan'; 
                    system.debug('----sta '+op.stagename);
                    system.debug('----sta '+op.ForecastCategoryName);       
                }
                if(prof.Name=='LDR Demand Gen' ){
                op.StageName='Zero Stage';
                op.ForecastCategoryName='Omitted';} 
                 
                if(op.recordTypeId==DXRecord){
                    op.StageName='Stage 1 - Qualification';
                    op.ForecastCategoryName='Pipeline';
                       
                }     
         }  
       }
    }
}