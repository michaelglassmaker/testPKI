@isTest (SeeAllData = true) 
public class PKIDuplicateTest {
    
    static testMethod void findDuplicateTest() {
        RecordType rt=[SELECT Id,Name FROM RecordType WHERE SobjectType='Account' and Name like 'Prospect%'];
        Account a = new Account(name='Test123456787', BillingStreet = '100 Main Street', BillingCity = 'Waltham', BillingState = 'MA', BillingCountry = 'US', BillingPostalCode = '02451', RecordTypeId=rt.Id);
        insert a;
        PageReference pf = Page.PKIDuplicateIdentification;
        pf.getParameters().put('id',a.id);
        Test.setCurrentPage(pf);
        pkiduplicate d=new pkiduplicate();
        
        //Delete account
        d.del.Parentid=a.id;
        PageReference r=d.sDelete();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        
        //Search Accounts
        d.criteria='Namaste';
        List<Account> la=[SELECT ID,NAME,PKI_Status__c,PKI_Account_Dup_Key__c,PKI_ParentChild__c,Site,
                          ShippingStreet,ShippingCountry,ShippingState,ShippingCity,RecordType.Name,
                          PKI_Account_Approvals__c,PKI_Approved_Owners__c,SAP_Customer_Number__c,No_of_Contacts_INF__c,
                          No_Of_Closed_Won_Opportunities_INF__c FROM Account WHERE RecordType.Name='Prospect' 
                          AND name like 'Namaste%'];
        r=d.Search();
        System.assertEquals(la.size(),d.rC);
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());

        //Cancel 
        r=d.Cancel();
        System.assertEquals('/' + a.id, r.getUrl());
        
        //Add
        Integer c=0;
        for(Account e:lA){
           pkiduplicate.Dups m=new pkiduplicate.Dups();
           c++;
           if(c==1)
               m.prn=true;
           if(c==4)
               break;
            m.chk=true;
            m.a=e;
            d.res.add(m);
            d.duplis.add(m);
        }
        r=d.Add();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        
        //Approve
        d.duplis[0].prn=false;
        r=d.Approve();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        System.debug('LIsT:' + d.duplis);
        
        //Parent
        d.duplis[0].chk=false;
        d.duplis[1].chk=true;
        d.duplis[2].chk=false;
        r=d.Parent();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        
        //remove
        d.duplis[1].chk=false;
        d.duplis[2].chk=true;
        d.vw='CRA';
        r=d.Remove();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        d.vw='CMFD';
        r=d.Remove();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        
        //Approve
        d.duplis[0].chk=true;
        d.duplis[1].chk=true;
        d.vw='CRA';
        r=d.Approve();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        d.vw='CMFD';
        r=d.Approve();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        
        //Unselect all
        d.vw='CRA';
        r=d.UnSelectAll();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        d.vw='CMFD';
        r=d.UnSelectAll();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        
        //Select All
        d.vw='CRA';
        r=d.SelectAll();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        d.vw='CMFD';
        r=d.SelectAll();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
        
        //Cancel Search
        r=d.ClearSearch();
        System.assertEquals('/apex/PKIDuplicateIdentification?id='+a.id,r.getUrl());
    }
}