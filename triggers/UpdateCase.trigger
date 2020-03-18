trigger UpdateCase on AccountTeamMember (after insert,After update, after delete) {
List<AccountTeamMember> team = new List<AccountTeamMember>();
List<AccountTeamMember> oldteam = new List<AccountTeamMember>();
 If(!Trigger.isDelete){
  team = [Select id, AccountId, User.Name, TeamMemberRole From AccountTeamMember Where id in :Trigger.NewMap.keySet()];
}
if(Trigger.isDelete || Trigger.isUpdate){
  Oldteam = [Select id, AccountId, User.Name, TeamMemberRole From AccountTeamMember Where id in :Trigger.OldMap.keySet() ALL ROWS];
}
Set<id> accid = new Set<Id>();
Map<Id,List<Case>> AccountCaseMap = new Map<Id,List<Case>>();
 for(AccountTeamMember a: team){
  accid.add(a.AccountId);
}
if(Trigger.isDelete){
       for(AccountTeamMember a: oldteam){
  			accid.add(a.AccountId);
	} 
 }
List<Case> relatedcases = [Select Id, AccountId,Account_Owner__c From Case Where AccountId in :accid and RecordType.Name like '%Informatics%'];
    for(Case c: relatedcases)  {
    if(AccountCaseMap.get(c.AccountId) == null)
      AccountCaseMap.put(c.AccountId,new List<Case>{c});
 	else
     AccountCaseMap.get(c.AccountId).add(c);    
    }
UpdateCasehandler uc = new UpdateCasehandler();
if(Trigger.isInsert){
  uc.updateCaseonTeamInsert(AccountCaseMap,team);
}
if(Trigger.isUpdate){
 uc.updateCaseonTeamUpdate(AccountCaseMap, team, Trigger.OldMap);
}
if(Trigger.isDelete){
  uc.updateCaseonTeamDelete(AccountCaseMap, Oldteam);  
}
}