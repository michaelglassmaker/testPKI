trigger INF_AccountContactDetailsUpdate on INF_Contracts_Req__c (before insert,before update) {
 
 
 String accDetails= null;
 String contDetails= null;
 
 Set<Id> oppIds = new Set<Id>();
 Set<Id> AccIds = new Set<Id>();
 Set<Id> ConIds = new Set<Id>();
  if(Trigger.isInsert){
    for(INF_Contracts_Req__c  custObj : Trigger.New)
    {
     
         oppIds.add(custObj.Opportunity_Name_INF__c);
    }
    
   List<Opportunity> OpList = [select Id,Name,AccountId,Primary_Contact__r.Id,Primary_Contact__r.name,Opportunity_Primary_Contact_INF__c,Primary_Contact__r.Email,Primary_Contact__r.Phone,
                               Primary_Contact__r.MailingStreet,Primary_Contact__r.MailingCity,Primary_Contact__r.MailingPostalCode,Primary_Contact__r.MailingState,Primary_Contact__r.MailingCountry
                                              from Opportunity where Id IN :oppIds];
    
   
   for(Opportunity opr : OpList )
   {
     ConIds.add(opr.Primary_Contact__r.Id);
     AccIds.add(opr.AccountId);
   } 
        
    
   List<Account> accList = [select Id,Name,ShippingStreet,ShippingCity,ShippingPostalCode,ShippingCountry,ShippingState
                                              from Account where id in: AccIds];
                                                           
   for(INF_Contracts_Req__c  cutObj : Trigger.New) 
  
   {
       
       cutObj.Name = cutObj.Contracts_Name__c;
       
       for(Account acc : accList)
       {
      
             if(acc.ShippingStreet!=null  ){
                 accDetails = acc.ShippingStreet;
             }
             else{
                 accDetails = '';
             }
           
             if(acc.ShippingCity!=null){
                 accDetails += '\n'+ acc.ShippingCity;
              }
             else{
                 accDetails +=  '';
             }
             
                   
             if(acc.ShippingState!=null){
                 accDetails += +'\n'+ acc.ShippingState;
                 }
                
             else{
                 accDetails +=  '';
             }
           
             if(acc.ShippingPostalCode!=null){
                 accDetails +='\n'+ acc.ShippingPostalCode;
                 }
                  else{
                 accDetails += '';
             }
           
             If(acc.ShippingCountry!=null){
                 accDetails +='\n'+ acc.ShippingCountry;
                 }
                  else{
                 accDetails +='';
             }
            
            if(accDetails!=null){
                 cutobj.Company_Details__c = accDetails;
              }
               else{
                 accDetails +='';
             }
                    
       }               
       
       for(Opportunity opt : OpList)
       {
                    
            if(opt.Primary_Contact__r.name!= null ){
            
                     contDetails = opt.Primary_Contact__r.name;
             }
             else{
                   contDetails = '';
             }
  
            if(opt.Primary_Contact__r.Email!=null){
                    contDetails = contDetails +'\n'+opt.Primary_Contact__r.Email;
                    }
            else{
                    contDetails= contDetails +'';
            }
              
            if(opt.Primary_Contact__r.Phone!=null){
                    contDetails = contDetails +'\n'+ opt.Primary_Contact__r.Phone;
                    }
                    else{
                    contDetails= contDetails +'';
            }
                    
            if(opt.Primary_Contact__r.MailingStreet!=null){
                    contDetails = contDetails +'\n'+ opt.Primary_Contact__r.MailingStreet;
                            }
                    else{
                    contDetails= contDetails +'';
            }
             
            if(opt.Primary_Contact__r.MailingCity!=null){
                    contDetails = contDetails +'\n'+ opt.Primary_Contact__r.MailingCity;
                    }
                    else{
                    contDetails= contDetails +'';
            }                   
                    
            if(opt.Primary_Contact__r.MailingState!=null && opt.Primary_Contact__r.MailingPostalCode!=null){
                    contDetails = contDetails +'\n'+ opt.Primary_Contact__r.MailingState +'-'+ opt.Primary_Contact__r.MailingPostalCode;
                    }
                    else{
                    contDetails= contDetails +'';
            }
            
            if(opt.Primary_Contact__r.MailingCountry!=null){
                    contDetails = contDetails +'\n'+ opt.Primary_Contact__r.MailingCountry;
                            }
                    else{
                    contDetails= contDetails +'';
            }
                           
            if(contDetails!=null)
                 cutObj.Contact_Details__c = contDetails; 
            
                    
       }  
               
    }   
     }
      List<INF_Contracts_Req__c> crlist = new List<INF_Contracts_Req__c>();
     if(Trigger.isUpdate){
     
    // List<INF_Contracts_Req__c> crlist = new List<INF_Contracts_Req__c>();
     
      for( INF_Contracts_Req__c crobj : [Select Company_Details__c,Contact_Details__c from INF_Contracts_Req__c where id IN :Trigger.new ]){
      
           crlist.add(crobj);
             
             
      }
      
     try{ 
        
      Update crlist;
      }
      catch(Exception e){
          system.debug('@@@@@@@' +e.getMessage());
          
      }
     }
          
 }