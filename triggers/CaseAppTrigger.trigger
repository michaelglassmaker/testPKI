trigger CaseAppTrigger on INF_Case_Application__c (before insert, before delete){
    /*CaseMergeControllerTest can be used for unit testing*/
    List<id> cids= new List<id>();
    List<Case> ctu=new List<Case>();
    Map<id,String> cmu=new Map<id,String>();
    String s=''; 
    
    if(Trigger.isInsert) {
        for (INF_Case_Application__c ca:Trigger.new){
            cids.add(ca.Case__c);
            if(cmu.containsKey(ca.Case__c)) {
                s=cmu.get(ca.Case__c);
                s = s + ';' + ca.INF_Application_Name__c;
                cmu.remove(ca.Case__c);
                cmu.put(ca.Case__c,s);
            } else {
                cmu.put(ca.Case__c,ca.INF_Application_Name__c);
            }
        }
    }
    
    if(Trigger.isDelete) {
        for (INF_Case_Application__c ca:Trigger.old){
            cids.add(ca.Case__c);
            if(cmu.containsKey(ca.Case__c)) {
                s=cmu.get(ca.Case__c);
                s = s + ';' + ca.INF_Application_Name__c;
                cmu.remove(ca.Case__c);
                cmu.put(ca.Case__c,s);
            } else {
                cmu.put(ca.Case__c,ca.INF_Application_Name__c);
            }
        }
    }
    
    map<id,Case> cm = new map<id,Case>([select id, INF_Application_Name__c from Case where id in :cids]);
    for(Case c:cm.values()) {
        s='';
        if(Trigger.isInsert) {
            s=c.INF_Application_Name__c + ';' + cmu.get(c.Id);
            s=s.replace(';;',';');
            s=s.replace('null;','');
            ctu.add(new Case(id=c.Id,INF_Application_Name__c=s));
        }
        if(Trigger.isDelete) {
            List<String> all=cmu.get(c.Id).split(';');
            s=c.INF_Application_Name__c;
            if(s!=null) {
                for(String p:all){
                   s=s.remove(p);
                   s=s.replace(';;',';');
                   List<String> sp=s.split(';');
                   s='';
                   for(String i:sp) {
                       if(s=='')
                           s=i;
                       else
                           s=s+';'+i;
                   }
                   ctu.add(new Case(id=c.Id, INF_Application_Name__c=s));
                }
            }
        }
    }
    if(ctu.size() > 0)
        update ctu;
}