@isTest
Public Class Test_BatchToUpdateAccountOwner{
    Public Static TestMethod void MyUnitTest1() {
        
    Profile p = [select Id,name from Profile where Name ='System Administrator'];
     User newUser = new User(
        profileId = p.id,
        username = 'newUserxxxxx@yahoo.com',
        email = 'pb@ff.com',
          emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname'
    );
    insert newUser;
    List<Account> accList = new List<Account>();
    for(Integer i=0; i<9; i++) {
        Account testAcc = new Account();
        testAcc.Name = 'AccountName'+i;
        testAcc.Account_Email__c = 'test'+i+'@test.com';
        testAcc.ShippingCountry = 'US';
        accList.add(testAcc);
    }
    
    insert accList;
    
    for(Account acc : accList){
        acc.OwnerId = UserInfo.getUserId();
    } 
    update accList;

    Test.startTest();
    BatchToUpdateAccountOwner batClass = new BatchToUpdateAccountOwner();
    Database.executeBatch(batClass);
    Test.stopTest();
        
    }
}