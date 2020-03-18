trigger SVMX_delFcoSchedule on FCO__c (before update) {
     set<id> fcoid=new set<id>();
    for(integer i=0;i<trigger.new.size();i++){       
        if(trigger.isupdate && trigger.new[i].PSC_Status__c =='Closed' && trigger.new[i].PSC_Status__c!= trigger.old[i].PSC_Status__c){
            fcoid.add(trigger.new[i].id);
        }
    }
    if(fcoid.size()>0){
        List<FCO_Schedule__c> fcosch=[select id from FCO_Schedule__c where fco__c IN:fcoid];
        if(fcosch.size()>0){
            delete fcosch;
        }
    }

}