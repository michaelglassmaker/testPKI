trigger account_state_of_incorporation_populate on Account (before insert, before update)
{
 for (account o: Trigger.new)
  {
   if ( (o.Account_Incorporated_State__c == null) || (o.Account_Incorporated_State__c != null))
     { o.State_of_Incorporation_Calc__c = o.Account_Incorporated_State__c; }
   }
}