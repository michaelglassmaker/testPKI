trigger CaseTrigger on Case (after insert,after update, before insert, before update) {
    system.debug('Entered Case trigger');
    CaseMethods cm = new CaseMethods(Trigger.OldMap, Trigger.Old, Trigger.NewMap, Trigger.New);
    
    if(Trigger.isBefore && Trigger.isInsert && CaseMethods.runBeforeInsert){
        system.debug('Before insert');
        CaseMethods.runOnceBeforeInsert();
        cm.updateCaseContact();  
        cm.serviceCase();
        cm.updatePriorityForQuality(); 
        cm.updateEntitlement();
        cm.updateCasewithAccountOwner(false,Trigger.new,null);
    }
    if(Trigger.isBefore && Trigger.isUpdate && CaseMethods.runBeforeUpdate){
        system.debug('Before update');
        CaseMethods.runOnceBeforeUpdate();
        cm.updateCaseContact();
        cm.serviceCase();
        cm.updatePriorityForQuality(); 
        cm.updateEntitlement();
        cm.updateCasewithAccountOwner(true,Trigger.new,Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        system.debug('After insert');
        cm.updateQualityCaseOnServiceCase();
        // cm.pushEvent();
        
        //below method used for Custom case audit
        cm.caseCustomAudit(); 
        
    }
    
    if(Trigger.isAfter && Trigger.isUpdate &&  CaseMethods.runAfterUpdate){
        system.debug('After Update');
        CaseMethods.runOnceAfterUpdate();
        //  cm.pushEvent();
        
        //below method used for Custom case audit
       cm.caseCustomAudit(); 
        
    }

    SMAX_PS_Utility.executeHandler(new SMAX_PS_CaseTriggerHandler());
}