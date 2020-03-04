public with sharing class searchAccountController {

 @AuraEnabled

public static List < account > fetchAccount(String searchKeyWord,String searchSAP,string searchCity, string searchStreet,string searchCountry) {
//Boolean PKIbase =false;
 String strSoqlQuery = 'Select  id, Name,PKI_SAP_Customer_Number__c,PKI_SAP_Customer_Base_Name__c,Opportunity_Info__c, ShippingCountry,ShippingCity, ShippingStreet,ShippingState,PKI_SAP_Name_3__c,PKI_SAP_Name_4__c from account where ';
String FixedFilter= '(PKI_SAP_Account_Group__c=\'0001\' OR PKI_SAP_Account_Group__c=\'SFDC\') AND (PKI_SAP_Marked_For_Deletion__c=false)' ;
    
    list <account> lstOfAccount= new list <account> ();
    
if(!string.isblank(searchKeyWord)){
string nam=searchKeyWord.trim();
 String NameKey ='%'+nam+'%';
FixedFilter+='AND Name LIKE \'%' + NameKey +  '%\' ' ;
}

if(!string.isblank(searchSAP)){
//string sap=searchSAP.trim();
 String sapNo =searchSAP;
FixedFilter+='AND PKI_SAP_Customer_Number__c=:sapNo ' ;
}

if(!string.isblank(searchStreet)){
//string site=searchStreet.trim();
 String siteS =searchStreet;
FixedFilter+='AND ShippingStreet LIKE \'%' + siteS +  '%\' ' ;
}

if(!string.isblank(searchCity)){
string street=searchCity.trim();
 String streetc ='%'+street+'%';
FixedFilter+='AND ShippingCity LIKE \'%' + streetc +  '%\' ' ;
}
    if(!string.isblank(searchCountry)){
string streetco=searchCountry.trim();
 String streetS ='%'+streetco+'%';
FixedFilter+='AND ShippingCountry=: streetco  ' ;
}


strSoqlQuery+=FixedFilter+' ORDER BY Opportunity_Info__c DESC LIMIT 200';
    system.debug('---strSoqlQuery '+strSoqlQuery);
    try{lstOfAccount= Database.query(strSoqlQuery);}catch (QueryException e){ system.debug('Query Exception:'+e.getMessage());return null;}

system.debug('---lstOfAccount '+lstOfAccount);

  return lstOfAccount;

}

}