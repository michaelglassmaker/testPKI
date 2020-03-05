trigger SerialNo on Lead_Agei__c (before insert) {

    Set<id> leadid=new Set<id>();
    for(Lead_Agei__c li:Trigger.new){
     leadid.add(li.Lead__c);
    }
    List<Lead_Agei__c> lageslno=[select id,Sl_No__c,Lead__c from Lead_Agei__c where Lead__c=:leadid];
    Integer counter;
    List<Integer> slnos=new List<Integer>();
        for(Lead_Agei__c l:Trigger.new){
            for(Lead_Agei__c l1:lageslno){
                   if(l1.Lead__c==l.Lead__c)
                   {
                    slnos.add(Integer.valueof(l1.Sl_No__c));
                   }
              }
              if(slnos.size()==0){
               counter=0;
              }
              else{
                slnos.sort();
                counter=slnos.get(slnos.size()-1);
              } 
              System.debug('Check 1');
              l.Sl_No__c=counter+1;
              slnos.clear();
        }
}