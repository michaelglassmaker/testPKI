trigger revenue_rec_date_populate on Opportunity (before insert, before update)
{
 Set<Id> recIds = new Set<Id>();
 Map<Id,String> rec_map = new map<id,String>();
 Map<Id,String> att_map = new map<id,String>();
 Set<id> Opp_ids = new Set<Id>();
 for(Opportunity o: Trigger.new){
  recIds.add(o.RecordTypeId);
  if(Trigger.isUpdate && o.stageName == 'Closed Won' && !Trigger.oldMap.get(o.id).StageName.contains('Stage 1')
              && !Trigger.oldMap.get(o.id).StageName.contains('Stage 2')
              && !Trigger.oldMap.get(o.id).StageName.contains('Stage 3'))
      Opp_ids.add(o.id);
 }
 if(Opp_ids.size() > 0){
 List<ContentDocumentLink> a = [SELECT ContentDocument.Title, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId in :Opp_ids and ContentDocument.Title like '%Quote%' ];
 for(ContentDocumentLink at:a){
   att_map.put(at.LinkedEntityId ,'true');
 }
 List<Attachment> att = [Select Name,Id,ParentId From Attachment Where parentid in :opp_Ids and name like '%Quote%'];
 for(Attachment at: att){
   att_map.put(at.Parentid,'true');
 }
 }
 for (opportunity o: Trigger.new)
  {
   if ( (o.Revenue_Rec_Date__c == null) || (o.Revenue_Rec_Date__c < o.CloseDate)&&( (o.recordtype.developername != 'Dx_EMEA_Record_Type') || (o.recordtype.developername != 'Informatics')) )
     { o.Revenue_Rec_Date__c = o.CloseDate + 5; }
     if(Trigger.isBefore && Trigger.isUpdate && o.Dealer_Portal_Opp__c == true && o.StageName == 'Closed Won' && att_map.get(o.id)== null
      && Opp_ids.contains(o.id) == true && ( Trigger.oldMap.get(o.id).StageName.contains('Stage 4')
              || Trigger.oldMap.get(o.id).StageName.contains('Stage 5')
              || Trigger.oldMap.get(o.id).StageName.contains('Stage 6'))){
        o.addError('Please attach the Quote Document to Close the Opportunity');
      }
  }if(Trigger.isBefore && Trigger.isInsert){
    Dealer_Portal_Opps_handler hld = new Dealer_Portal_Opps_handler();
    hld.isDealerPortalOpp(recIds,Trigger.New);
  } 
   if(Trigger.isInsert || Trigger.isUpdate){
       Handler_HCSCollaboration hcs = new Handler_HCSCollaboration(Trigger.new,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
       hcs.populateHTSRep();
   } 
  
}