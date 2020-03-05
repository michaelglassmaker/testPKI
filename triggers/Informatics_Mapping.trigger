trigger Informatics_Mapping on Demo_Log__c (Before Insert,Before Update,After Insert) {

  
  Set<Id> Opp_Ids = New Set<id>();
  Set<String> Primary_Emails = new Set<String>();
  List<Demo_Log__c> demos = new List<Demo_Log__c>();
  Map<String,Informatics_Demologs_Mapping__mdt> Demo_Map = New map<String,Informatics_Demologs_Mapping__mdt>();
  Country_Region_Mapping cr = new Country_Region_Mapping();
  For(Demo_Log__c d: trigger.new){
    if((Trigger.isInsert ||
       (Trigger.isUpdate && (Trigger.oldMap.get(d.id).Primary_Product_INF__c != d.Primary_Product_INF__c || Trigger.oldMap.get(d.id).Region_INF__c!= d.Region_INF__c)))
      && d.RecordTypeId == Schema.getGlobalDescribe().get('Demo_Log__c').getDescribe().getRecordTypeInfosByName().get('Informatics').getRecordTypeId()
     ){
        Opp_Ids .add(d.Opportunity__c);
        demos.add(d);
    }
  }
  Map<Id,Opportunity> opp = new Map<Id,Opportunity>();
  if(Opp_ids.size() > 0) 
      opp  = new Map<Id,Opportunity>([select Id,Name From Opportunity Where Id in :Opp_Ids]);
  
  for(Informatics_Demologs_Mapping__mdt i: [Select Product_Line__c,Region__c,primary_Contact__c,CC_List__c From Informatics_Demologs_Mapping__mdt]){
    Demo_Map.put(i.Product_Line__c + '-' + i.Region__c, i);
    Primary_Emails.add(i.primary_Contact__c);
  }
  List<User> u = [select id,Name,Email,username From User Where username in :Primary_Emails];
  Map<String,User> Primary_UserMap = new Map<String,user>();
  for(User prUser: u){
    Primary_UserMap.put(prUser.username,prUser);
  }
  if(Trigger.isBefore){
  for(Demo_Log__c d: demos){
     if(Demo_Map.size() > 0
     && Primary_UserMap.size() >0
     && d.Region_INF__c != null
     && cr.GetGlobalRegion(d.Region_INF__c) != null 
     && Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)) != null
     && Primary_UserMap.get(Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)).primary_Contact__c) != null){
       d.Demo_Lead_INF__c = Primary_UserMap.get(Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)).primary_Contact__c).Id;
    }
   }
  }
  if(Trigger.isAfter){
   for(Demo_Log__c d: demos){
       String[] sendingTocAdd;
       if(Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)) != null 
         && Primary_UserMap.get(Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)).primary_Contact__c) != null){
       
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{Primary_UserMap.get(Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)).primary_Contact__c).Email};
        semail.setToAddresses(sendingTo);
        String htmlbody = '<HTML><body>Dear '+ Primary_UserMap.get(Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)).primary_Contact__c).Name +',<br />Received new demo request, details given below:<br>Opportunity Name - ' + opp.get(d.Opportunity__c).Name + '<br />Primary Product -  ' + d.Primary_Product_INF__c + '<br />Activity -  ' + d.Activity_INF__c + '<br />Demo Notes - ' + d.Demo_Notes_INF__c +'<br />Demo Scheduled Date - ' + d.Scheduled_Date_INF__c + '<br/>Current Status - ' + d.Status_INF__c + '<br/><br/>Click here to view the detailed record - <a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() +'/'+d.id + '">' +  System.URL.getSalesforceBaseUrl().toExternalForm() +'/'+ d.id + '</a></body></HTML>';
        system.debug(htmlbody);
        if(opp.get(d.Opportunity__c) != null)
        semail.setSubject(' New Demo Request for' + opp.get(d.Opportunity__c).Name);
        semail.setHTMLBody(htmlbody);
        semail.setSaveAsActivity(false);
        if(Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)).CC_List__c != null || Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)).CC_List__c != ' '){
        sendingTocAdd = Demo_Map.get(d.Primary_Product_INF__c + '-' + cr.GetGlobalRegion(d.Region_INF__c)).CC_List__c.Split(',');
        }
        semail.setCcAddresses(sendingTocAdd);
        semail.setTemplateId('00X30000001jJfX');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
     }
   }
  }
 
}