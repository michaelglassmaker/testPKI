public class AcctCTRL{
    public static MainWrapper wrapMain ;   
    @AuraEnabled
    public static string init()
    {
        wrapMain = new MainWrapper();
        try{
            wrapMain.currentuser=new User();
            wrapMain.currentuser=[Select Id,Name,Email from User where Id=:userinfo.getuserId()];
            if(wrapMain.currentuser.Name !=null && wrapMain.currentuser.Name !='')
                wrapMain.strLoginUserName = wrapMain.currentuser.Name;
            
            wrapMain.success = true;
        }
        catch(exception e){
            wrapMain.success = false;
            wrapMain.errorMessage = e.getMessage();
        }
        return Json.serialize(wrapMain);
    }
    @AuraEnabled
    public static string SearchAccount(string strAccountName, string strcity, string strBillingCountry)
    {
        wrapMain = new MainWrapper();
        try{
            
            if(strAccountName !=null && strAccountName !='' && strcity !=null && strcity !='' && strBillingCountry !=null && strBillingCountry !='')
            {
                wrapMain.currentuser=new User();
                wrapMain.currentuser=[Select Id,Name,Email from User where Id=:userinfo.getuserId()];
                if(wrapMain.currentuser.Name !=null && wrapMain.currentuser.Name !='')
                    wrapMain.strLoginUserName = wrapMain.currentuser.Name;
                
                List<Account> lstAcc = new List<Account>();
                string strSearchAccountName = '%'+strAccountName+'%';
                string strSearchCity = '%'+strcity+'%';
                string strSearchCountry = '%'+strBillingCountry+'%';
                string strSearchSite = '%'+'PRIMARY'+'%';
                DescribeSObjectResult describeResult = Account.getSObjectType().getDescribe();     
                List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                String query = ' SELECT ' + String.join( fieldNames, ',') +' '+'FROM Account Where Name LIKE: strSearchAccountName and BillingCity LIKE: strSearchCity and PKI_SAP_Account_Group__c =\'0001\' and Site LIKE:strSearchSite and BillingCountry LIKE: strSearchCountry';
                
                system.debug('query...'+query);
                lstAcc = Database.query( query );
                if(lstAcc != null && lstAcc.size() > 0){
                   wrapMain.lstAccount = lstAcc;
                }
                wrapMain.success = true;
            }
        }
        catch(exception e){
            wrapMain.success = false;
            wrapMain.errorMessage = e.getMessage();
        }
        return Json.serialize(wrapMain);
    }
    public class MainWrapper{
        public boolean success;
        public string errorMessage;
        public sObject sObjAcc;
        public string strLoginUserName;
        public user currentuser;
        @AuraEnabled
        public List<Account> lstAccount{get;set;}
    }
}