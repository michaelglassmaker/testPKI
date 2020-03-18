trigger svmx_insFCOSchedule on FCO_Search__c (after insert,before update) {
    List<FCO_Search__c> fcosChn=new List<FCO_Search__c>();
    List<FCO_Search__c> fcosdel=new List<FCO_Search__c>();
    set<id> fcosChnid=new set<id>();
    set<id> fcosdelid=new set<id>();
    List<FCO_Schedule__c> fsList=new List<FCO_Schedule__c>();
    for(integer i=0;i<trigger.new.size();i++){
        if(trigger.isinsert && trigger.new[i].schedule_time__c != null){
            FCO_Schedule__c fs=new FCO_Schedule__c();
            fs.FCO_Search__c=trigger.new[i].id;
            fs.Active__c=true;
            fs.Scheduled_Time__c=trigger.new[i].schedule_time__c;
            fs.FCO__c=trigger.new[i].fco__c;
            fsList.add(fs);
        }
        if(trigger.isupdate && trigger.new[i].schedule_time__c != trigger.old[i].schedule_time__c){
            fcosChn.add(trigger.new[i]);
            fcosChnid.add(trigger.new[i].id);           
        }
    }    
    if(fcosChn.size()>0){
       List<FCO_Schedule__c> fsins=new List<FCO_Schedule__c>();
       List<FCO_Schedule__c> fsupd=new List<FCO_Schedule__c>();
       List<FCO_Schedule__c> chkFS=[select id,Scheduled_Time__c,FCO_Search__c from FCO_Schedule__c where FCO_Search__c IN:fcosChnid];
       Boolean chk=true;
       for(FCO_Search__c fs:fcosChn){
           chk=true;
           for(FCO_Schedule__c f:chkFS){
               if(f.FCO_Search__c == fs.id){
                   FCO_Schedule__c fs1=new FCO_Schedule__c(id=f.id);
                   fs1.Scheduled_Time__c=fs.schedule_time__c;
                   fsupd.add(fs1);
                   chk=false;
               }
           }
           if(chk==true){
               FCO_Schedule__c fs2=new FCO_Schedule__c();
               fs2.FCO_Search__c=fs.id;
               fs2.Active__c=true;
               fs2.Scheduled_Time__c=fs.schedule_time__c;
               fs2.FCO__c=fs.fco__c;
               fsins.add(fs2);
           }
       }
       if(fsupd.size()>0){
            update fsupd;
        }
        if(fsins.size()>0){
            insert fsins;
        }       
    }

    
    if(fsList.size()>0){
        insert fsList;
    }
    
}