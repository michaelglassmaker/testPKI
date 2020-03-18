trigger account_category_calc_populate on Account (before insert, before update)
{
 for (account o: Trigger.new)
  {
   if ( (o.Account_Category__c == null) || (o.Account_Category__c != null))
     { o.Account_Category_Calc__c = o.Account_Category__c; }
   }
}