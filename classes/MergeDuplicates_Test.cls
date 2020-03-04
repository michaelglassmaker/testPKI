@isTest (SeeAllData = true) 
public class MergeDuplicates_Test {

static testMethod void mergeAccountsTest() 
{
        PageReference pf = Page.PKIDuplicateIdentificationDuplicate;
        Test.setCurrentPage(pf);
        mergeDuplicates mergeacc =new mergeDuplicates();
        
        //Search Accounts
        mergeacc.accName ='MERCK & CO';
        mergeacc.shippingSate = 'PA';
        mergeacc.acclist_size = 5;
        List<Account> la=[SELECT ID,Phone,Fax,AnnualRevenue,Sales_Territory__c,NAME,PKI_Status__c,PKI_Account_Dup_Key__c,PKI_ParentChild__c,
                                Site,ShippingStreet,ShippingPostalCode,ShippingCountry,ShippingState,ShippingCity,BillingPostalCode,BillingStreet,BillingCountry,BillingState,BillingCity,PKI_Account_Approvals__c,PKI_Approved_Owners__c,SAP_Customer_Number__c
                                FROM Account 
                                WHERE (RecordType.Name='Prospect Account' OR RecordType.Name='PKI-Master' OR RecordType.Name='Customer')
                                AND Name like 'MERCK & CO%' AND ShippingState ='PA' LIMIT 5];
        
        PageReference r= mergeacc.Search();       
        System.assertEquals(la.size(),mergeacc.resCount);
            
        // Pagination test
         mergeacc.nextAccount();
         mergeacc.previousAccount();
         mergeacc.first();
         mergeacc.lastAccount();
         
        for(Account a:la)
        {
          mergeDuplicates.myWrapperClass mw =new mergeDuplicates.myWrapperClass();
                    mw.acc = a;
                    mw.selected = true;
                    mw.RecordType = mergeacc.getAccountRecordType(a.Id);
                    mw.ShippingAddress = (String.isblank(a.ShippingStreet)? '' : a.ShippingStreet) + '\n' + (String.isblank(a.ShippingCity)? '' : ',' + a.ShippingCity)  + (String.isblank(a.ShippingState)? '' : a.ShippingState) + ' ' + (String.isblank(a.ShippingPostalCode)? '' : a.ShippingPostalCode) +'\n' + (String.isblank(a.ShippingCountry)? '' : a.ShippingCountry);
                    mw.BillingAddress = (String.isblank(a.BillingStreet)? '' : a.BillingStreet) + '\n' + (String.isblank(a.BillingCity)? '' : ',' + a.BillingCity)  + (String.isblank(a.BillingState)? '' : a.BillingState) + ' ' + (String.isblank(a.BillingPostalCode)? '' : a.BillingPostalCode) +'\n' + (String.isblank(a.BillingCountry)? '' : a.BillingCountry);
                    mergeacc.accResults.add(mw);
        }

        // Proceed with selected accounts
        mergeacc.ProceedWithSelected();
        
        for(mergeDuplicates.myWrapperClass selectedmw : mergeacc.accResults)
        {
                if(selectedmw.selected == true)
                {
                       if(selectedmw.RecordType == 'Customer')
                          {
                              selectedmw.isMasterselected = true;
                          }
                       else
                          {
                            selectedmw.isMasterselected = false;
                          }
                          
                        selectedmw.isSiteselected = false;
                        selectedmw.isStreetselected = false;
                        selectedmw.isCountryselected = false;
                        selectedmw.isStateselected = false;
                        selectedmw.isCityselected = false; 
                        selectedmw.isFaxselected= false; 
                        selectedmw.isSalesOfficeselected= false; 
                        selectedmw.isPhoneselected= false; 
                        selectedmw.isAnnualRevenue= false; 
                        mergeacc.accSelectedResults.add(selectedmw);
                       
                }
        }

        //Merge Accounts  
         mergeDuplicates.myWrapperClass myaccReq = new mergeDuplicates.myWrapperClass();
         
         
         List<Id> duplicateIds =null;
        for(mergeDuplicates.myWrapperClass selectedMergeObj: mergeacc.accSelectedResults)
        {
            
            
            if(selectedMergeObj.RecordType == 'Customer')
                             {
                               selectedMergeObj.acc.Merged_Flag__c = true; 
                               selectedMergeObj.acc.IsExcludedFromRealign= false;
                             }
              if(selectedMergeObj.isMasterselected == true)
                {
                      myaccReq.masterRecord = selectedMergeObj.acc;       
                }
                else
                {
                  duplicateIds = new List<Id>();
                  duplicateIds.add(selectedMergeObj.acc.Id);
                 
                }
                 
        }
  
        //myaccReq.dupAccountIds = duplicateIds;
        //Database.MergeResult[] results = Database.merge(myaccReq.masterRecord, myaccReq.dupAccountIds);
       
        mergeacc.MergeAccounts(); 
 
}

static testMethod void mergeContactsTest() 
    {

        PageReference pf = Page.PKIDuplicateIdentificationDuplicate;
        Test.setCurrentPage(pf);
        mergeDuplicates mergecon =new mergeDuplicates();
     
        //Search Contacts
        mergecon.cont.AccountId ='0015B00000MWAAtQAP';
        mergecon.fName= 'br';
        mergecon.list_size = 5;
        mergecon.counter =0;
        List<Contact> lc=[SELECT Id,Phone,FirstName,PKI_SAP_Customer_Number__c,LastName,Email,MailingStreet, MailingCity, MailingState, MailingCountry FROM Contact
                          WHERE AccountId='0015B00000MWAAtQAP' and FirstName like 'br%' LIMIT 5];
                                 
        PageReference r= mergecon.findContacts();    
        System.assertEquals(lc.size(),mergecon.resCount);
             
        // Pagination test
         mergecon.Next();
         mergecon.Previous();
         mergecon.Beginning();
         mergecon.End();
         
        for(Contact c:lc)
        {
          mergeDuplicates.myContactWrapperClass wrapConRec =new mergeDuplicates.myContactWrapperClass();
                    wrapConRec.con = c;
                    wrapConRec.AccountName = mergecon.getAccountName(c.Id);
                    wrapConRec.isConSelected = true;
                    mergecon.contactResults.add(wrapConRec);        
        }
        
        // Proceed with selected contacts
        mergecon.SelectedContacts();
        
        for(mergeDuplicates.myContactWrapperClass selectedWrapObj: mergecon.contactResults)
        {
                if(selectedWrapObj.isConSelected == true)
                {
                       if(selectedWrapObj.con.PKI_SAP_Customer_Number__c != null)
                          {
                              selectedWrapObj.isMasterselected = true;
                          }
                       else
                          {
                            selectedWrapObj.isMasterselected = false;
                          }
                          
                        selectedWrapObj.isfNameSelected = false;
                        selectedWrapObj.islNameSelected = false;
                        selectedWrapObj.isStreetselected = false;
                        selectedWrapObj.isCountryselected = false;
                        selectedWrapObj.isStateselected = false;
                        selectedWrapObj.isCityselected = false; 
                        selectedWrapObj.isPhoneselected= false;
                        mergecon.conMergeResults.add(selectedWrapObj);
                       
                }
        
        }

         mergeDuplicates.myContactWrapperClass myReq = new mergeDuplicates.myContactWrapperClass();
         List<Account> masterRecObject = new List<Account>();
         List<Id> duplicateIds =null;
         
        for(mergeDuplicates.myContactWrapperClass selectedMergeObj: mergecon.conMergeResults)
        {
            
             if(selectedMergeObj.isMasterselected == true)
                {
                      myReq.masterRecord = selectedMergeObj.con;       
                }
                else
                {
                  duplicateIds = new List<Id>();
                  duplicateIds.add(selectedMergeObj.con.Id);
                 
                }
        }
             
       // myReq.dupContactIds = duplicateIds;
       // Database.MergeResult[] results = Database.merge(myReq.masterRecord, myReq.dupContactIds);
      // Merge contacts
        mergecon.mergeContacts(); 
    }
}