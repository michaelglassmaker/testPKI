trigger account_sub_category_calc_populate on Account (before insert, before update)
{
 for (account o: Trigger.new)
  {
   if ( (o.Account_Sub_Category__c == null) || (o.Account_Sub_Category__c != null))
     { o.Account_Sub_Category_Calc__c = o.Account_Sub_Category__c; }
   }
}