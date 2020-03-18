trigger CopyCaseApplications on INF_Case_Survey__c (after insert) {
 Set<id> parentRecordId = new Set<Id>();
 List<Case_Survey_Applications__c> caseapplsurveytoinsert = new List<Case_Survey_Applications__c>();
  for(INF_Case_Survey__c casesurveylist : Trigger.new){
        parentRecordId.add(casesurveylist.Case__c);
        
    }
    
    List<INF_Case_Application__c> caseapp = [select Id,INF_Application_Name__c,INF_Application_Product_Group__c,INF_Application_Product_Line__c from INF_Case_Application__c
                                            where Case__c IN : parentRecordId];
                                            
        for(INF_Case_Application__c caseapplication : caseapp){
            for(INF_Case_Survey__c casesurveylist : Trigger.new){
            Case_Survey_Applications__c casesurveyapp = new Case_Survey_Applications__c();
            casesurveyapp.Case_Survey__c = casesurveylist.id;
            casesurveyapp.Application_Name__c = caseapplication.INF_Application_Name__c;
            casesurveyapp.Application_Product_Group__c = caseapplication.INF_Application_Product_Group__c;
            caseapplsurveytoinsert.add(casesurveyapp);
            }
        }
        
        if(caseapplsurveytoinsert.size() > 0){
            insert caseapplsurveytoinsert;
        }

}