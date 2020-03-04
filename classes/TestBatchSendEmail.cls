@isTest
private class TestBatchSendEmail {
    
    static testMethod void myUnitTest() {
        test.startTest();
        
            //custom settings insertion Open_Lead_Notice__c 
            Open_Lead_Notice__c leadNotice = new Open_Lead_Notice__c();
            leadNotice.Name = '2';
            leadNotice.Id1__c = '00QV00000054Bd0MAE;00QV00000054BdFMAU;00QV00000054BdKMAU;00QV00000054BdjMAE;00QV00000054CIPMA2;00QV00000054CIUMA2;00QV00000054CIZMA2;00QV00000054CIeMAM';
            leadNotice.Id2__c = '';
            insert leadNotice;
            
            //Send_mail_settings insertion
            Send_Mail_Settings__c sm = new Send_Mail_Settings__c();
            sm.name = 'mail settings';
            sm.bcc_mails__c = 'test@testmail.com;sendmail@mail.com';
            sm.allowed_productlines__c = 'AA; AMS; ASO; GC; ICP; IR; LC; LCM; MAS; One Source: Multi-vendor; One Source: Qualification; One Source: Relocation; One Source: Training; RAM; Service Contract; SVC; TEA; TOF; UVS';
            insert sm;
            
            //Lead  insertion
            String countryNames = Label.CountryEmailInclude;
            List<String> countriesInclude = countryNames.split(',');
            List<Lead> leadsToInsert = new List<Lead>();
            for(Integer i=0;i<5;i++)
            {
                leadsToInsert.add(new Lead(LastName='Name'+i,product_Line__c='AA',Company='Company'+i,Country=countriesInclude.get(i),Status='Open'));
            }
            insert leadsToInsert;
            
            //call batch method
            BatchSendMail bse = new BatchSendMail();
            Database.executeBatch(bse);
            
        test.stopTest();
    }
    
    static testMethod void testScheduleSendEmail(){
        test.startTest();
            //Send_mail_settings insertion
            Send_Mail_Settings__c sm = new Send_Mail_Settings__c();
            sm.name = 'mail settings';
            sm.bcc_mails__c = 'test@testmail.com;sendmail@mail.com';
            sm.Schedule_send_mail__c = false;
            insert sm;
            
            Schedule_BatchSendEmail sh1 = new Schedule_BatchSendEmail();
            String sch = '0 0 23 * * ?';
            System.Schedule('Test Schedule', sch, sh1);
        test.stopTest();
    }
}