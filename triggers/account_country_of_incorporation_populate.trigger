trigger account_country_of_incorporation_populate on Account (before insert, before update)
{
 for (account o: Trigger.new)
  {
   if ( (o.Account_Incorporated_Country__c == null) || (o.Account_Incorporated_Country__c != null))
     { o.Country_of_Incorporation_Calc__c = o.Account_Incorporated_Country__c; }
   }
}