/* Change Log
 * 
  Developer         Date        Description
  Tony Tran         01/24/17    Removed commented code, removed code that referenced deleted methods
 * 
 */ 

trigger AccountTrigger on Account (before insert, before update,after insert, after update,before delete)
{
     //Call constructor  
     AccountMethods am = new AccountMethods(Trigger.OldMap, Trigger.Old, Trigger.NewMap, Trigger.New);
    
     if(Trigger.isAfter && Trigger.isInsert && AccountMethods.run) {
        AccountMethods.runOnceInsert();
        system.debug('inside insert');
        //am.changeTopParent(true);
     }
    
     if(Trigger.isAfter && Trigger.isUpdate &&  AccountMethods.runUpdate) {
        AccountMethods.runOnceUpdate();
        system.debug('inside update');
        system.debug('new trigger values'+trigger.new);
        //am.changeTopParent(false);
     }
    
     if(Trigger.isBefore && Trigger.isInsert){        
        am.updateAccountvalues();
        //sets the account owner field to PerkinElmer Inc
        am.setAccountOwner();
     }
    
     if(Trigger.isBefore && Trigger.isUpdate)
        am.updateAccountvalues();
     
     if(Trigger.isBefore && Trigger.isDelete)
        //check record type and prevent deletion
        am.preventDeleteBasedOnRecordType();
     
     if(trigger.isBefore &&(trigger.isinsert || trigger.isupdate)) {
         Sobject sobj = Trigger.new[0];
         am.validatesobjectvalues(String.valueOf(sobj.getSobjectType()));
     }
        
}