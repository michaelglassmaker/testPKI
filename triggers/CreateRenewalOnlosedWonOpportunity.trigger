/**********************************************************
*Created By: Lister technologies
*Purpose: For Informatics Opportunities,to create Renewal Opportunities on closed won status grouped with the 
*         closed date of the products in it. 
************************************************************/
trigger CreateRenewalOnlosedWonOpportunity on Opportunity (before insert, before update, after update) {
    
    //Set Account Type based on PriceBook
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for(Opportunity opp: trigger.new) {
            if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics) {
                if(opp.pricebook2Id == '01s0x0000002GWX' || opp.pricebook2Id == '01s3A000000HydI') {
                    opp.Account_Type_INF__c = 'Government';
                } else if(opp.pricebook2Id == '01s0x0000002GWc' || opp.pricebook2Id == '01s3A000000HydD'){
                    opp.Account_Type_INF__c = 'Academic';
                } else {
                    opp.Account_Type_INF__c = 'Commercial';
                }
            }
         }
     }
    
    //Logic which will work only during creation of Informatics Opportunity for all types excluding the Renewal
    if(Trigger.isBefore && Trigger.isInsert)
    {
        Set<Id> setOfAccId = new Set<Id>();
        //Collecting Account Ids from the Opportunities created
        for(Opportunity opp: trigger.new)
        {
            if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics && opp.Type != 'Renewal')
            {
                setOfAccId.add(opp.AccountId);
            }
        }

        if(setOfAccId.size()>0)
        {
            //Create a map of Account Id to Account Record based on the Account Ids collected
            Map<Id,Account> mapOfAccIdToAccName = new Map<Id,Account>([Select Id,Name from Account where Id IN:setOfAccId]);
            //Naming Opportunities in the format : INF_AccountName_MM/YYYY 
            for(Opportunity opp: trigger.new)
            {
                if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics && opp.Type != 'Renewal')
                {
                    list<String> listOfBusinessLine = new list<String>();
                    //Checking whether AccountId from Opportunity is available in the map constructed
                    if(mapOfAccIdToAccName.containsKey(opp.AccountId))
                    {
                        /*Naming Convention : INF_AccountName_ProductFamily_month/year*/
                        // for insert : INF_AccountName_month/Year
                        // opp.Name='INF_'+mapOfAccIdToAccName.get(opp.AccountId).Name + '_' +opp.CloseDate.month()+'/'+opp.CloseDate.year();
                        opp.Opportunity_Alias_INF__c = 'INF_'+mapOfAccIdToAccName.get(opp.AccountId).Name + '_' +opp.CloseDate.month()+'/'+opp.CloseDate.year();
                    }
                }
            }
        }
    }

    //Code to get executed for Opportunity renewals
    if(Trigger.isUpdate && !Utility_Informatics.isRenewed)
    {
        Set<Id> setOfOpp = new Set<Id>();
        Set<Id> setOfOpp_NonRenew = new Set<Id>();
        Set<Id> setOfOpp_AllClosed = new Set<Id>();
        Set<Id> setOfOpp_Informatics = new Set<Id>();
        List<Opportunity> listOfNewOpp = new List<Opportunity>();
        OpportunityLineItem[] OLPerpetual = new OpportunityLineItem[]{};
        Map<Id,Opportunity> mapOfOldOppIdToOldOpp = new Map<Id,Opportunity>();
        Map<Id,Set<Date>> mapOfOppIdToNewOppDate = new Map<Id,Set<Date>>();
        Map<Id,List<OpportunityLineItem>> mapOfOppIdToOppLineItems = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,List<OpportunityLineItem>> mapOfOppIdToOppLineItems_Informatics = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,List<OpportunityContactRole>> mapOfOppIdToOppContactRoles = new Map<Id,List<OpportunityContactRole>>();
        map<Id,String> mapOfProductFamilyName = new map<Id,String>();
        map<Id,String> mapOfAccountName = new map<Id,String>();
        //Collecting set of products under the Informatics price Book for Renewal
        Id priceBookId;
        set<string> productSet = new set<string>();
        set<string> perpproductSet = new set<string>();
        
        //Data lists added by Santosh - post Go live
        set<Id> set_Opps_gettingSumitted = new set<Id>();
        
        //system.debug('Product Set size :'+productSet.size());                                   
        //system.debug('Product Set  :'+productSet); 
        
        //naming Convention code
        if(Trigger.isBefore){
            //Checking if the bulk load is informatics
            for(Opportunity opp: trigger.new){
                if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics){
                    setOfOpp_Informatics.add(opp.Id);
                }
            }
            List<Opportunity> Optylist1 = [SELECT ID,CloseDate, Account.Name, Type, 
                                           (SELECT ID, PriceBookEntry.Name FROM OpportunityLineItems), 
                                           Name FROM Opportunity Where ID in:setOfOpp_Informatics];
            //System.debug('>>> setOfOpp_Informatics: '+setOfOpp_Informatics.size()+'## :'+setOfOpp_Informatics);
            //querying for the oppo and opp lineitems
            for(Opportunity iterating_Opp : Optylist1 ){
                //mapOfOppIdToOppLineItems_Informatics.add(Id, itearting_Opp.OpportunityLineItems);
                set<String> unique_ProductFamily = new set<String>();
                //iterating the set of line items
                //System.debug('>>> iterating_Opp: '+iterating_Opp);
                //System.debug('>>> iterating_Opp.OpportunityLineItems: '+iterating_Opp.OpportunityLineItems);
                for(OpportunityLineItem iterating_produtLineItem : iterating_Opp.OpportunityLineItems){
                    unique_ProductFamily.add(iterating_produtLineItem.PriceBookEntry.Name.split('-',2)[0].trim());
                }
                //iterating the name of products
                //System.debug('&&&&&&&&&&');
                String productName= '';
                for(String iterating_String : unique_ProductFamily){
                    if(productName == '')
                        productName = iterating_String;
                    else
                        productName = productName + '-' + iterating_String;
                }
                //Logic for name added
                //iterating_Opp.Name = 'INF_'+iterating_Opp.Account.Name + '_' + productName + '_' + iterating_Opp.CloseDate.month()+'/'+iterating_Opp.CloseDate.year();
                //System.debug('@@@@' + iterating_Opp.Name);
                if(iterating_Opp.Type != 'Renewal')
                {
                    mapOfProductFamilyName.put(iterating_Opp.Id,iterating_Opp.Account.Name + '_' + productName );
                    mapOfAccountName.put(iterating_Opp.Id,iterating_Opp.Account.Name);
                }
                else
                {
                    mapOfProductFamilyName.put(iterating_Opp.Id,iterating_Opp.Account.Name + '_' + productName + '_REN_'); 
                    mapOfAccountName.put(iterating_Opp.Id,iterating_Opp.Account.Name);
                } 
            }
            
            //Adding the name finally
            for(Opportunity iterating_Opp : Trigger.new){ 
                if(mapOfAccountName.containsKey(iterating_Opp.Id)) {
                    iterating_Opp.Opportunity_Alias_INF__c= 'INF_'+ mapOfAccountName.get(iterating_Opp.Id) + '_' + iterating_Opp.CloseDate.month()+'/'+iterating_Opp.CloseDate.year();
                    break;
                }
            }
        }
        if(Trigger.isAfter){
            //Constructing set of Opportunity Ids from the trigger, with conditions - only for Closed Won stage,of RecordType Informatics,Renewal Required is Yes and Run Rate Opp field is unchecked.    
            for(Opportunity opp: trigger.new) {
                if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics && opp.StageName == 'Closed Won'
                   && ((Trigger.oldMap.get(opp.Id).StageName!=Trigger.newMap.get(opp.Id).StageName) 
                       || (Trigger.oldMap.get(opp.Id).Renewal_Required_INF__c!=Trigger.newMap.get(opp.Id).Renewal_Required_INF__c) 
                       || (Trigger.oldMap.get(opp.Id).Run_Rate_Opp_INF__c!=Trigger.newMap.get(opp.Id).Run_Rate_Opp_INF__c)) 
                   && opp.Renewal_Required_INF__c == 'Yes' && opp.Run_Rate_Opp_INF__c != true)
                {
                    If(opp.SBQQ__PrimaryQuote__c==null) //Only If primary quote is null : Shashi 5/3/2018
                        setOfOpp.add(opp.Id);
                }
                
                if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics && opp.StageName == 'Closed Won'
                   && opp.Renewal_Required_INF__c == 'No'
                   && opp.Run_Rate_Opp_INF__c != true)
                {
                    setOfOpp_NonRenew.add(opp.Id);
                }
                
                if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics && opp.StageName == 'Closed Won')
                {
                    setOfOpp_AllClosed.add(opp.Id);
                }
                //Changed by Santosh post go live to ensure that data blank should not trigger any error
                //Adding the Opportunity if its informatics record type, stage = Stage 6 - Implement (Closed) and previous stage was not the same.
                if(opp.RecordTypeId == Utility_Informatics.opportunity_Informatics && opp.StageName == 'Stage 6 - Implement (Closed)' && (Trigger.oldMap.get(opp.Id).StageName!=Trigger.newMap.get(opp.Id).StageName)){
                    set_Opps_gettingSumitted.add(opp.Id);
                }
            }
            
            for(Opportunity oppRen:[Select Id,(Select Id From Originating_Opportunity__r) From Opportunity where Id IN:setOfOpp])
            {
                if(oppRen.Originating_Opportunity__r.size()>0)
                    setOfOpp.remove(oppRen.Id);
            }
        }
        
        //Adding the logic to check for the start date and end date
        //Added by Santosh Post Go Live
        if(!set_Opps_gettingSumitted.isEmpty()){
            //Querying for price book
            priceBookId = [SELECT Id,Name FROM Pricebook2 where name = 'Informatics'].id;
            
            //Querying for product line items
            //for(PricebookEntry pbeObj:[SELECT Id,Name FROM PricebookEntry where Pricebook2Id =:priceBookId   and (name like '%Subscription%' or name like '%Maint%' or name like '%Term%' or name like '%Perpetual%')]){
            //productSet.add(pbeObj.name);
            
            for(PricebookEntry pbeObj:[SELECT Id,Product2.License_Type_INF__c,Name FROM PricebookEntry where Pricebook2Id =:priceBookId   and Product2.License_Type_INF__c IN('Subscription','Term','Maintenance','Perpetual Maintenance','SaaS','PaaS','Term Maintenance')]){
                productSet.add(pbeObj.Product2.License_Type_INF__c);
            }
            
            for(Opportunity opp:[Select o.Type,o.Probability, o.OwnerId, o.Originating_Opportunity_INF__c,o.LeadSource, 
                                 o.Name,o.Id,o.CurrencyIsoCode,
                                 o.CloseDate, o.Amount, o.Account_Class_INF__c, o.AccountId,o.Account.Name,o.Primary_Contact__r.LastName,o.RecordTypeId,o.CampaignId,
                                 (Select Type_INF__c, PricebookEntry.Product2.License_Type_INF__c,Start_Date_INF__c, Product_Status__c, Product_Line__c,Quantity, Product_Family__c,
                                  OpportunityId, Id, End_Date_INF__c,PricebookEntryId,UnitPrice,Product_Name_INF__c From OpportunityLineItems
                                  where PricebookEntry.Product2.License_Type_INF__c IN :productSet), 
                                 //where Product_Name_INF__c IN :productSet ),
                                 (Select Id, OpportunityId, ContactId, Role, IsPrimary From OpportunityContactRoles)
                                 From Opportunity o where Id IN:set_Opps_gettingSumitted])
            {
                for(OpportunityLineItem oppLitem:opp.OpportunityLineItems)
                {
                    //if(oppLitem.End_Date_INF__c == NULL  || oppLitem.Start_Date_INF__c == NULL)
                    //if(oppLitem.PricebookEntry.Product2.License_Type_INF__c.contains('Perpetual') && oppLitem.Start_Date_INF__c == NULL)
                    //Trigger.newMap.get(opp.Id).addError('Enter the START DATE for PERPETUAL products to submit order');
                    //else 
                    if(   (
                        oppLitem.PricebookEntry.Product2.License_Type_INF__c.contains('Subscription') 
                        ||
                        oppLitem.PricebookEntry.Product2.License_Type_INF__c.contains('Maintenance') 
                        ||
                        oppLitem.PricebookEntry.Product2.License_Type_INF__c.contains('Term')                               
                        
                    )
                       &&
                       (
                           oppLitem.End_Date_INF__c == NULL  
                           ||
                           oppLitem.Start_Date_INF__c == NULL
                       )
                      )
                        Trigger.newMap.get(opp.Id).addError('Enter the START DATE and END DATE for SUBSCRIPTION, MAINTENANCE and TERM products to submit order');
                }
            }
        }
        
        
        //The following code block populates StartDate on complete order
        //The following code block creates the Assets for NonRenewalOpportunities
        if(setOfOpp_NonRenew.size()>0)
        {
            Asset[] astNonrenew = new Asset[]{};
                for(Opportunity oppnonrenew:[Select o.Type,o.Probability, o.OwnerId, o.Originating_Opportunity_INF__c,o.LeadSource, 
                                             o.Name,o.Id,o.CurrencyIsoCode,o.Account_Type_INF__c,o.Booked_Date_INF__c,o.Quote_Created_Date__c,o.Quote_Number__c,o.GP_OrderNum_INF__c,
                                             o.CloseDate, o.Amount, o.Account_Class_INF__c, o.AccountId,o.Account.Name,o.Primary_Contact__r.LastName,o.RecordTypeId,o.CampaignId,
                                             (Select PricebookEntry.Product2Id,PricebookEntry.ProductCode,PricebookEntry.Product2.Name, Description,Type_INF__c, Start_Date_INF__c,Product_Status__c, Product_Line__c,Quantity, Product_Family__c,
                                              OpportunityId, Id, End_Date_INF__c,PricebookEntryId,TotalPrice,UnitPrice From OpportunityLineItems
                                             )  
                                             From Opportunity o where Id IN:setOfOpp_NonRenew])
            {
                
                OpportunityLineItem[] OL = new OpportunityLineItem[]{};
                    Asset aNonRenew = new Asset();
                if(oppnonrenew.OpportunityLineItems.size()>0)
                {
                    for(OpportunityLineItem oppli:oppnonrenew.OpportunityLineItems)
                    {
                        
                        aNonRenew = new Asset();
                        aNonRenew.AccountId = oppnonrenew.AccountId;
                        aNonRenew.Product2Id = oppli.PricebookEntry.Product2Id;
                        aNonRenew.Price= oppli.TotalPrice;
                        aNonRenew.Account_Type__c = oppnonrenew.Account_Type_INF__c;
                        aNonRenew.Booked_Date__c = oppnonrenew.Booked_Date_INF__c;
                        aNonRenew.Quote_Date__c =  oppnonrenew.Quote_Created_Date__c;
                        aNonRenew.Quote_Number__c = oppnonrenew.Quote_Number__c;
                        aNonRenew.Sales_Order_Number__c = oppnonrenew.GP_OrderNum_INF__c;
                        aNonRenew.Quantity = oppli.Quantity;
                        aNonRenew.Unit_Price_LC__c =  oppli.UnitPrice;
                        aNonRenew.PurchaseDate = oppnonrenew.CloseDate;
                        aNonRenew.Status = 'Purchased';
                        
                        aNonRenew.Description = oppli.Description;
                        
                        if(oppnonrenew.Name.length() > 10)
                        {
                            aNonRenew.Name = oppnonrenew.Name.substring(0,10)+ '-'  + oppli.PricebookEntry.Product2.Name.substring(0,5) + '-' + '_INF';
                        }
                        else
                        {
                            aNonRenew.Name = oppnonrenew.Name + '-'  + oppli.PricebookEntry.Product2.Name.substring(0,5) + '-' + '_INF';
                        }
                        //a.End_Date__c = oppli.End_Date_INF__c.addYears(1);
                        //a.Start_Date__c = oppli.End_Date_INF__c.addDays(1);
                        aNonRenew.Opportunity__c = oppnonrenew.Id;
                        aNonRenew.Is_Informatics__c =true;
                        astNonrenew.add(aNonRenew);
                    }
                }
            }  
            insert astNonrenew;
        }
        if(setOfOpp_AllClosed.size()>0) {
            System.debug('BookedDate Test Before: ' + Date.today());
            for(Opportunity opp1:[Select o.Id,o.Originating_Opportunity_INF__c,o.Booked_Date_INF__c,
                                  (Select PricebookEntry.Product2Id,PricebookEntry.Product2.License_Type_INF__c,TotalPrice, PricebookEntry.Product2.Name,PricebookEntry.ProductCode, Description,Type_INF__c, Start_Date_INF__c,
                                   OpportunityId, Id, End_Date_INF__c From OpportunityLineItems
                                   where PricebookEntry.Product2.License_Type_INF__c = 'Perpetual')  
                                  From Opportunity o where o.Id IN:setOfOpp_AllClosed])
            {
                System.debug('BookedDate Test: '+opp1.Booked_Date_INF__c);
                if(opp1.OpportunityLineItems.size()>0)
                { 
                    for(OpportunityLineItem oppliper:opp1.OpportunityLineItems)
                    {
                        System.debug('BookedDate1: '+opp1.Booked_Date_INF__c);
                        
                        oppliper.Start_Date_INF__c=Date.today();
                        oppliper.End_Date_INF__c = null;
                        OLPerpetual.add(oppliper);
                    }
                    //if(OLPerpetual.size()>0) update OLPerpetual;
                }
            }
            if(OLPerpetual.size()>0)
                update OLPerpetual; 
        }
        
        if(setOfOpp.size()>0){
            //Querying for price book
            priceBookId = [SELECT Id,Name FROM Pricebook2 where name = 'Informatics'].id;
            
            //Querying for product line items
            //for(PricebookEntry pbeObj:[SELECT Id,Name FROM PricebookEntry where Pricebook2Id =:priceBookId   and (name like '%Subscription%' or name like '%Maint%' or name like '%Term%')]){
            //productSet.add(pbeObj.name);
            
            for(PricebookEntry pbeObj:[SELECT Id,Product2.License_Type_INF__c,Name FROM PricebookEntry where Pricebook2Id =:priceBookId   and Product2.License_Type_INF__c IN('Subscription','Term','Maintenance','Perpetual Maintenance','SaaS','Term Maintenance')]){
                productSet.add(pbeObj.Product2.License_Type_INF__c);
            }
            
            
            //Querying Opportunity records along with Opportunity Line Items and Contact Roles based on the Opportunity Ids collected and only for Maintenance,Subscription and Term Products.

            for(Opportunity opp:[Select o.Type,o.Strategic_Market_INF__c,o.Probability, o.OwnerId, o.Territory.Id,o.Originating_Opportunity_INF__c,o.LeadSource, 
                                 o.Name,o.Id,o.CurrencyIsoCode,o.Account_Type_INF__c,o.Booked_Date_INF__c,o.Quote_Created_Date__c,o.Quote_Number__c,o.GP_OrderNum_INF__c,
                                 o.CloseDate, o.Amount, o.Account_Class_INF__c, o.AccountId,o.Account.Name,o.Primary_Contact__r.LastName,o.RecordTypeId,o.CampaignId,
                                 (Select PricebookEntry.Product2Id,PricebookEntry.Product2.License_Type_INF__c, PricebookEntry.Product2.Name,PricebookEntry.ProductCode, Description,Type_INF__c, Start_Date_INF__c, Product_Status__c, Product_Line__c,Quantity, Product_Family__c,
                                  OpportunityId, Id, End_Date_INF__c,PricebookEntryId,Converted_To_Asset__c,UnitPrice From OpportunityLineItems
                                  where PricebookEntry.Product2.License_Type_INF__c IN :productSet), 
                                 //where Product_Name_INF__c IN :productSet ),
                                 (Select Id, OpportunityId, ContactId, Role, IsPrimary From OpportunityContactRoles)
                                 From Opportunity o where Id IN:setOfOpp])
            {
                mapOfOldOppIdToOldOpp.put(opp.Id,opp);
                //Mapping Opportunity Id with OpportunityLineItems List
                if(opp.OpportunityLineItems.size()>0)
                    mapOfOppIdToOppLineItems.put(opp.Id,opp.OpportunityLineItems);
                Set<Date> newOppDateSet = new Set<Date>();

                //Collect all the Dates from OpportunityLineItems under an Opportunity and Mapping to Opportunity Id

                for(OpportunityLineItem oppLitem:opp.OpportunityLineItems)
                {
                    newOppDateSet.add(oppLitem.End_Date_INF__c);
                }
                mapOfOppIdToNewOppDate.put(opp.Id,newOppDateSet);
                //Mapping OpportunityContactRoles to Opportunity Id
                mapOfOppIdToOppContactRoles.put(opp.Id,opp.OpportunityContactRoles);
                
            }

            //The following code block creates the Renewal Opportunities from an opportunity.
            //The total number of Renewal Opportunities from a opportunity is decided by the mapOfOppIdToNewOppDate,which will give the dates count for an opportunity
            //The code loops over for all the dates collected under every opportunity and creates Renewal opportunities linked to the source opportunity
            for(Id oppId: setOfOpp)
            {
                for(Date d:mapOfOppIdToNewOppDate.get(oppId))
                {
                    OppResetControl.DoNotReset = true;
                    Opportunity opold = mapOfOldOppIdToOldOpp.get(oppId);
                    Opportunity opnew = opold.clone(false,true);
                    //Close Date is determined by the End date of Opportunity Line Item's End Date
                    opnew.CloseDate = d;
                    opnew.RecordTypeId = opold.RecordTypeId;
                    opnew.Type='Renewal';
                    //Renewal Opportuniites will follow same naming convention but additionally include keyword "REN" next to Account Name
                    System.debug('Account Name'+ opold.Account.Name);
                    System.debug('Date'+ d);
                    opnew.Name='INF_'+opold.Account.Name+'_REN_'+d.month()+'/'+d.year(); 
                    opnew.Opportunity_Alias_INF__c =    'INF_'+opold.Account.Name+'_REN_'+d.month()+'/'+d.year(); 
                    opnew.Amount = 0;
                    opnew.TerritoryId = opold.Territory.Id;
                    opnew.Probability=90;
                    opnew.StageName='Stage 5 - Negotiation';
                    opnew.Message_Stage_Progression__c = 'Verbal commitment to buy from PKI';
                    opnew.Commit_INF__c = 'Yes';
                    opnew.Booked_Date_INF__c=null;
                    opnew.Quote_Created_Date__c = null;
                    opnew.GP_OrderNum_INF__c = null;
                    //Linking to the Source Opportunity
                    opnew.Originating_Opportunity_INF__c = opold.Id;
                    //Code to set prior year order number : 11/7/2017 - Shashi Puttaswamy
                    if(opold.GP_OrderNum_INF__c!=null)
                        opnew.PY_Order_Number__c = opold.GP_OrderNum_INF__c;
                    listOfNewOpp.add(opnew);
                }
            }
            try{
                insert listOfNewOpp;
            }catch(DMLException e)
            {
                //System.debug('>>> Error inserting Cloned Opportunities:'+e.getStackTraceString());
            }
            // Code to create task for renewal opportunities
            List<Task> renewaltasks = new List<Task>();
            for(Opportunity opprenew:listOfNewOpp) {
                Task tsk = new Task(whatID = opprenew.Id, Ownerid = opprenew.OwnerId,Subject=opprenew.Name+'-Renewal Reminder',ActivityDate=opprenew.CloseDate-90);
                renewaltasks.add(tsk);
            }
            insert renewaltasks;
            
            //System.debug('>>> New Opportunities: '+listOfNewOpp);
            List<OpportunityLineItem> oppLitemNewList = new List<OpportunityLineItem>();
            List<OpportunityContactRole> oppContactRoleNewList = new List<OpportunityContactRole>();
            Asset[] ast = new Asset[]{};
            OpportunityLineItem[] OLSubRenew = new OpportunityLineItem[]{};
                    
            OpportunityLineItem[] OROLineItem = new OpportunityLineItem[]{};
            Asset[] astrenew = new Asset[]{};
            OpportunityLineItem[] OLRenew = new OpportunityLineItem[]{};
            //Code to get all the OpportunityLineItems from Source Opportunity and assigning them to corresponding Renewal Opportunities based on the Closed Date
            for(Opportunity oppnew:listOfNewOpp){
                //System.debug('>>> oppnew: '+oppnew.Id);
                if(mapOfOppIdToOppLineItems.containsKey(oppnew.Originating_Opportunity_INF__c) && (mapOfOppIdToOppLineItems.get(oppnew.Originating_Opportunity_INF__c).size()>0))
                {   
                    for(OpportunityLineItem oppli:mapOfOppIdToOppLineItems.get(oppnew.Originating_Opportunity_INF__c))
                    {
                        if(oppli.End_Date_INF__c == oppnew.CloseDate)
                        {
                            OpportunityLineItem oppLiTemp = oppli.clone(false,true);
                            oppLiTemp.OpportunityId = oppnew.Id;
                            oppLiTemp.Start_Date_INF__c = oppLiTemp.End_Date_INF__c.addDays(1);
                            oppLiTemp.End_Date_INF__c = oppLiTemp.End_Date_INF__c.addYears(1);
                            oppLitemNewList.add(oppLiTemp);
                        }
                        Asset a = new Asset();
                        a.AccountId = oppnew.AccountId;
                        a.Product2Id = oppli.PricebookEntry.Product2Id;
                        a.Quantity = oppli.Quantity;
                        a.Price= (oppli.Quantity * oppli.UnitPrice);
                        a.Account_Type__c = oppnew.Account_Type_INF__c;
                        a.Booked_Date__c = oppnew.Booked_Date_INF__c;
                        a.Quote_Date__c =  oppnew.Quote_Created_Date__c;
                        a.Quote_Number__c = oppnew.Quote_Number__c;
                        a.Sales_Order_Number__c = oppnew.GP_OrderNum_INF__c;
                        a.Unit_Price_LC__c =  oppli.UnitPrice;
                        a.PurchaseDate = oppnew.CloseDate;
                        a.Status = 'Purchased';
                        a.Description = oppli.Description;
                        if(oppnew.Name.length() > 10)
                        {
                            a.Name = oppnew.Name.substring(0,10)+ '-'  + oppli.PricebookEntry.Product2.Name.substring(0,5) + '-' +oppli.End_Date_INF__c.addYears(1).month()+'/'+oppli.End_Date_INF__c.addYears(1).day()+'/'+oppli.End_Date_INF__c.addYears(1).year() + '_INF';
                        }
                        else
                        {
                            a.Name = oppnew.Name + '-'  + oppli.PricebookEntry.Product2.Name.substring(0,5) + '-' +oppli.End_Date_INF__c.addYears(1).month()+'/'+oppli.End_Date_INF__c.addYears(1).day()+'/'+oppli.End_Date_INF__c.addYears(1).year() + '_INF';
                        }
                        a.End_Date__c = oppli.End_Date_INF__c.addYears(1);
                        a.Start_Date__c = oppli.End_Date_INF__c.addDays(1);
                        a.Renewal_Opportunity__c= oppnew.Id;
                        a.Opportunity__c = oppnew.Originating_Opportunity_INF__c;
                        a.Is_Informatics__c =true;
                        ast.add(a);
                    }
                }
                //Code to clone OpportunityContact Role Records from Source Opportunity and link to all the newly created Opportunities
                if(mapOfOppIdToOppContactRoles.containsKey(oppnew.Originating_Opportunity_INF__c) && (mapOfOppIdToOppContactRoles.get(oppnew.Originating_Opportunity_INF__c).size()>0))
                {   
                    for(OpportunityContactRole oppCR:mapOfOppIdToOppContactRoles.get(oppnew.Originating_Opportunity_INF__c))
                    {
                        //System.debug('>>> 2: '+oppnew.Id);
                        OpportunityContactRole oppCRTemp = oppCR.clone(false,true);
                        oppCRTemp.OpportunityId = oppnew.Id;
                        oppContactRoleNewList.add(oppCRTemp);
                    }
                }
            }
            
            
            //DML to perform insertion of newly cloned Opportunity Line Items and opportunity Contact Roles
            try{
                insert oppLitemNewList;
                insert oppContactRoleNewList;
                insert ast;
                
                
                if(OROLineItem.size()>0)
                {
                    update OROLineItem;
                }
                
                
            }catch(DMLException e)
            {
                //System.debug('>>> Error inserting Cloned Opportunity Child Relations:'+e.getStackTraceString());
            }
            
            
            //The following code block creates the Assets for RenewalOpportunities other than //Maintenance,Subscription and Term Products
            //These Assets will not attach to renewal opportunities.
            for(Opportunity opp:[Select o.Type,o.Probability, o.OwnerId, o.Originating_Opportunity_INF__c,o.LeadSource, 
                                 o.Name,o.Id,o.CurrencyIsoCode,o.Account_Type_INF__c,o.Booked_Date_INF__c,o.Quote_Created_Date__c,o.Quote_Number__c,o.GP_OrderNum_INF__c,
                                 o.CloseDate, o.Amount, o.Account_Class_INF__c, o.AccountId,o.Account.Name,o.RecordTypeId,o.CampaignId,
                                 (Select PricebookEntry.Product2Id,TotalPrice, PricebookEntry.Product2.Name,PricebookEntry.ProductCode, Description,Type_INF__c, Start_Date_INF__c, Product_Status__c, Product_Line__c,Quantity, Product_Family__c,
                                  OpportunityId, Id, End_Date_INF__c,PricebookEntryId,UnitPrice From OpportunityLineItems
                                  where PricebookEntry.Product2.License_Type_INF__c NOT IN('Term','Subscription','Maintenance'))  
                                 From Opportunity o where Id IN:setOfOpp])
            {
                if(opp.OpportunityLineItems.size()>0)
                {
                    Asset a = new Asset();
                    for(OpportunityLineItem oppli:opp.OpportunityLineItems)
                    {
                        
                        a = new Asset();
                        a.AccountId = opp.AccountId;
                        a.Product2Id = oppli.PricebookEntry.Product2Id;
                        a.Quantity = oppli.Quantity;
                        a.Price= oppli.TotalPrice;
                        a.Account_Type__c = opp.Account_Type_INF__c;
                        a.Booked_Date__c = opp.Booked_Date_INF__c;
                        a.Quote_Date__c =  opp.Quote_Created_Date__c;
                        a.Quote_Number__c = opp.Quote_Number__c;
                        a.Sales_Order_Number__c = opp.GP_OrderNum_INF__c;
                        a.Unit_Price_LC__c =  oppli.UnitPrice;
                        a.PurchaseDate = opp.CloseDate;
                        a.Status = 'Purchased';
                        a.Description = oppli.Description;
                        if(opp.Name.length() > 10)
                        {
                            a.Name = opp.Name.substring(0,10)+ '-'  + oppli.PricebookEntry.Product2.Name.substring(0,5) + '-' + '_INF';
                        }
                        else
                        {
                            a.Name = opp.Name + '-'  + oppli.PricebookEntry.Product2.Name.substring(0,5) + '-' + '_INF';
                        }
                        //a.End_Date__c = oppli.End_Date_INF__c.addYears(1);
                        //a.Start_Date__c = oppli.End_Date_INF__c.addDays(1);
                        a.Opportunity__c = opp.Id;
                        a.Is_Informatics__c =true;
                        
                        astrenew.add(a);
                    }
                }
            }
            try
            {
                insert astrenew;
            }
            catch(DMLException e)
            {
                //System.debug('>>> Error inserting asets:'+e.getStackTraceString());
            } 
            //Boolean to stop re-execution of the same trigger within same event - basically to stop re-execution caused by workflow or other Triggers.
            Utility_Informatics.isRenewed = true;   
        }
    }
}