/*
Created By : Lister Technologies
Purpose : This trigger run whenever a record is created and sets the account owner field to PerkinElmer Inc. It also adds the user who created this account as the account team member with membership role as 'Account Member'.
Test Class : Test_trg_setAccountowner 
Modified By : 
*/
trigger trg_setAccountOwner on Account (After insert) {
    User defaultAccountOwner=[select name,id from user where Username='perkinelmerinc@perkinelmer.com.pkisbxfull'];
        if(defaultAccountOwner!=null){
            List<AccountTeamMember> accTeamMemberListToInsert=new List<AccountTeamMember>();
            List<Account> accountListToUpdate=new List<Account>();
            List<AccountShare> listtoinsertaccountshare=new List<AccountShare>();
            
            accountListToUpdate=[select id,Ownerid from account where id in :Trigger.new];
            for(Account iter : accountListToUpdate){
                AccountTeamMember accTeamMember=new AccountTeamMember();
                accTeamMember.AccountId=iter.id;
                accTeamMember.TeamMemberRole='Account Manager';
                accTeamMember.UserId=iter.ownerid;
                accTeamMemberListToInsert.add(accTeamMember);
                iter.Ownerid=defaultAccountOwner.id;
                AccountShare accshare=new AccountShare(AccountId=iter.id,CaseAccessLevel='Read',UserOrGroupId=accTeamMember.UserId,AccountAccessLevel='Edit',OpportunityAccessLevel='Read');
                listtoinsertaccountshare.add(accshare);

            }
            
            update accountListToUpdate;
            insert   accTeamMemberListToInsert;
            insert listtoinsertaccountshare;

        }              
}