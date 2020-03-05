/*
     Change History
    ******************************************************************************************************************************************
         JIRA       ModifiedBy        Date            Requested By                           Description                              Purpose
    ******************************************************************************************************************************************
        SFDC-491    Ashwini         28/4/2017        Ian Brown             Request Enhancements 2.0 (JIRA)   Auto populate the name of the requestor on request creation
        
*/


trigger updateNameOfTheRequestor on Requests__c (before insert) {
//  user defaultuser = [select id from user where name = 'default user'];

   for (Requests__c record:trigger.new)
    {
   if(record.Name_of_Requestor__c ==null) 
   {

          record.Name_of_Requestor__c = userinfo.getUserId();

        }

      }

    }