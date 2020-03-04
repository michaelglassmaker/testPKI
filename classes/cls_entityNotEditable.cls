/***********************************************************
Created By          : Lister technologies
Purpose             : To ensure that Account with record type - Perkin Entities should not be editable
Created Date        : 18th November 2013
Last Modified Date  : 18th November 2013
Test Class Name     : 
Version             : 1.0 -- 18th November 2013 - First Version
************************************************************/
public class cls_entityNotEditable {
    
    //variable intialisation 
    public Account runnning_account;
    map<Id, String> map_AccountRecordType = new map<Id,String>();
    map<Id, String> map_AccountRecordType2 = new map<Id,String>();
    List<User> userProfile = new List<User>();
    //public Boolean bln_isError{get; set;} 
    public String VF_page_old_URL{get; set;}
    public String VF_page_new_URL{get; set;}
    public String profileName{get; set;}
    public Id result;
    // The extension constructor initializes the public member
    // variable runnning_account by using the getRecord method from the standard
    // controller.
    public cls_entityNotEditable(ApexPages.StandardController stdController) {
        
        runnning_account = (Account)stdController.getRecord();
        bln_isError      = false;
        
        PageReference pageRef   = ApexPages.currentPage();
        result = UserInfo.getUserId();
        userProfile = [Select profile.Name from User where Id =: result];
        profileName = userProfile.get(0).profile.Name;
        system.debug('!@@@###' + profileName);
        VF_page_old_URL  = pageRef.getParameters().get('retURL');
        system.debug('VF_page_new_URL' + VF_page_new_URL);
        VF_page_new_URL  = '/' + runnning_account.Id +'/e?retURL='+VF_page_old_URL+'&nooverride=1';
        system.debug('VF_page_new_URL' + VF_page_new_URL);
        
        //Querying the Account record type details
        for(RecordType iterating_RecordType : [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'PerkinElmer_Entities']){
            map_AccountRecordType.put(iterating_RecordType.Id, iterating_RecordType.DeveloperName);
        }
        for(RecordType iterating_RecordType : [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'Dx_Managed_Market']){
            map_AccountRecordType2.put(iterating_RecordType.Id, iterating_RecordType.DeveloperName);
        }
       
    }
    

    public Boolean bln_isError{
        get{
            if(profileName == 'System Administrator')
                bln_iserror = false;
            else if(map_AccountRecordType.containsKey(runnning_account.RecordTypeId))
               bln_isError = true;
            else if((map_AccountRecordType2.containsKey(runnning_account.RecordTypeId) && profileName == 'Dx Managed Market')){
                bln_isError = false;
            }
            return bln_isError;
         }
         set{}
    }
    
    
}