@isTest(seeAllData=true)
private class TestCreateRenewalOppClosedWon {
static testMethod void CreateRenewalOnlosedWonOpportunity(){
Set<Id> SetOfOppIds = new Set<Id>();
    
    /* Added by Gireesh AccountId='0013000001DIhdl' */
    List<Opportunity> newOpps = new List<Opportunity>();
     List<Opportunity> listOfOpp = new List<Opportunity>();
     
     Account ac = new Account ();
          
            ac.name='Test Account';
            ac.shippingCountry = 'US';
            ac.shippingStreet = 'Street1';
            ac.shippingCity = 'City1';
            ac.shippingState = 'State';
            ac.shippingCountry ='US';
            ac.shippingPostalCode = '12345';
            ac.Industry ='Biotech';
            ac.CurrencyIsoCode = 'USD';
            ac.BillingStreet = 'Street1';
            ac.BillingCity = 'City1';
            ac.BillingState = 'State';
            ac.BillingCountry ='US';
            ac.BillingPostalCode = '12345';
            insert ac;
            
           /* Insert an Contact */
           Contact co = new Contact ();
           co.AccountId=ac.id;
           co.FirstName='Test Name';
           co.LastName='Test';
           insert co;
    
        for (Integer i = 0; i < 10; i++)
         {  
             
            // RecordType optyrecordtype = [select id from recordType where Name='informatics' limit 1];
           newOpps.add(new Opportunity(Name='opp'+i,AccountId=ac.Id,Probability=99,Renewal_Required_INF__c='Yes',RecordTypeId='01230000001aIi6',Account_Type_INF__c='Academic',Primary_Contact__c=co.Id,StageName='Stage 7 - Submit Order',CloseDate=Date.today(),Revenue_Rec_Date__c = Date.today(),Solution_Area_of_Interest__c='Energy'));
         }
        insert newOpps;
        
        
//get standard pricebook
Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];


Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1');
insert pbk1;

Product2 prd1 = new Product2 (Name='Term test',ProductCode='CPH567',License_Type_INF__c='Services',Product_Type_INF__c='Services',Description='Test Product Entry 1');
insert prd1;

Product2 prd2 = new Product2 (Name='test product',ProductCode='CPH568',License_Type_INF__c='Services',Product_Type_INF__c='Services',Description='Test Product Entry 2');
insert prd2;

Product2 prd3 = new Product2 (Name='test product',ProductCode='CPH569',License_Type_INF__c='Services',Product_Type_INF__c='Services',Description='Test Product Entry 3');
insert prd3;



PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPb.id,IsActive=true,
        UseStandardPrice=false,UnitPrice=50);
insert pbe2;

// Create a task for each one
List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();
List<Opportunity> OppsUpdate = new List<Opportunity>();
  

for(Opportunity opp : newOpps){
newLineItems.add(new OpportunityLineItem(OpportunityID=opp.id,Start_Date_INF__c=Date.today(),End_Date_INF__c=Date.today(),TotalPrice=10,Quantity=1,PriceBookEntryID=pbe2.id));
//newLineItems.add(new OpportunityLineItem(OpportunityID=opp.id,Start_Date_INF__c=Date.today(),End_Date_INF__c=Date.today(),TotalPrice=10,Quantity=1,PriceBookEntryID=pbe2.id));
SetOfOppIds.add(opp.id);
}
insert newLineItems;

 /*for(Opportunity op :[Select Id,
                          (Select Type_INF__c, PricebookEntry.Product2.License_Type_INF__c,Start_Date_INF__c, Product_Status__c,
                           Product_Line__c,Quantity, Product_Family__c,OpportunityId, Id, End_Date_INF__c,PricebookEntryId,
                           UnitPrice,PricebookEntry.Product2.Product_Type_INF__c From OpportunityLineItems
                           WHERE (PricebookEntry.Product2.License_Type_INF__c ='Services' OR PricebookEntry.Product2.Product_Type_INF__c ='Services'))                                    
                        From Opportunity o where Id IN:SetOfOppIds]){
    
    if(op.OpportunityLineItems.size()>0)
    {
       for(OpportunityLineItem opp : op.OpportunityLineItems)
           {
             op.Order_Processing_Status_INF__c = 'Revenue Review Required';
             listOfOpp.add(op);           
           } 
             if(listOfOpp.size()>0)
                  update listOfOpp;    
      } 
}*/

    
}

    
}