@isTest
public class PDG_Test_Lead_Routing {
    public static string OwnerChangeId;
    @testSetup static void setup() {
        List <Lead> LeadContainer = new List <Lead>();
        List <Contact> ConContainer = new List <Contact>();
        List <User> UserContainer = new List <User>();
        SAI_Lead_Routing_Values__c cc = new SAI_Lead_Routing_Values__c();
        PDG_Public_Group_Names__c pubGrNames = new PDG_Public_Group_Names__c();
		//PDG_Queue__c pdg = new PDG_Queue__c();
        //pdg.PDG_Lead_Queue__c = '00Gn0000001ax9C';
        //insert pdg;
        
        
        for(integer i=0; i<=8; i++){
            if(i<5){
                            User al = new User(FirstName = 'aUser'+i,
                               Username = 'ausere'+i+'@test.com', 
                               LastName = 'Test', 
                               Email = 'ausere'+i+'@test.com', 
                               Alias = 'ausere'+i+'@', 
                               CommunityNickname = 'user'+i+'@', 
                               TimeZoneSidKey = 'America/New_York',
                               LocaleSidKey = 'en_US',
                               EmailEncodingKey = 'ISO-8859-1',             
                               ProfileId = '00e30000000czPE', 
                               LanguageLocaleKey = 'en_US',
            				   ManagerId = '0053A00000DPNX3QAP');
            UserContainer.add(al);
            }else{
                            User al = new User(FirstName = 'aUser'+i,
                               Username = 'ausere'+i+'@test.com', 
                               LastName = 'Test', 
                               Email = 'ausere'+i+'@test.com', 
                               Alias = 'ausere'+i+'@', 
                               CommunityNickname = 'user'+i+'@', 
                               TimeZoneSidKey = 'America/New_York',
                               LocaleSidKey = 'en_US',
                               EmailEncodingKey = 'ISO-8859-1',             
                               ProfileId = '00e30000000czPE', 
                               LanguageLocaleKey = 'en_US');
            UserContainer.add(al);
            }
          
        }
        insert UserContainer;
        
        Group WARM_Americas = new Group(Name = 'PDG Warm Americas');
        Group WARM_EMEA = new Group(Name = 'PDG Warm EMEA');
        Group WARM_APAC = new Group(Name = 'PDG Warm APAC');
        Group Hot_Americas = new Group(Name = 'PDG Hot Americas');
        Group Hot_EMEA = new Group(Name = 'PDG Hot EMEA');
        Group Hot_APAC = new Group(Name = 'PDG Hot APAC');
        Group RouteDx = new Group(Name = 'PDG LDR To Dx');
        Group RouteGROW = new Group(Name = 'PDG GROW LDRs');
        
        insert WARM_Americas;
        insert WARM_EMEA;
        insert WARM_APAC;
        insert Hot_Americas;
        insert Hot_EMEA;
        insert Hot_APAC;
        insert RouteDx;
        insert RouteGROW;
        
        System.runAs(UserContainer[0]) {
            GroupMember PDG_WARM_Americas = new GroupMember(UserOrGroupId = UserContainer[0].id, GroupId = WARM_Americas.Id);
            system.debug('[Test-Class] <PDG_Test_Lead_Routing> GroupMember PDG_WARM_Americas : ' + PDG_WARM_Americas);
            insert PDG_WARM_Americas;
        }
        System.runAs(UserContainer[1]) {
            GroupMember PDG_WARM_EMEA = new GroupMember(UserOrGroupId = UserContainer[1].id, GroupId = WARM_EMEA.Id);
            system.debug('[Test-Class] <PDG_Test_Lead_Routing> GroupMember PDG_WARM_EMEA : ' + PDG_WARM_EMEA);
            insert PDG_WARM_EMEA;
        }
        System.runAs(UserContainer[2]) {
            GroupMember PDG_WARM_APAC = new GroupMember(UserOrGroupId = UserContainer[2].id, GroupId = WARM_APAC.Id);
            system.debug('[Test-Class] <PDG_Test_Lead_Routing> GroupMember PDG_WARM_APAC : ' + PDG_WARM_APAC);
            insert PDG_WARM_APAC;
        }
        System.runAs(UserContainer[3]) {
            GroupMember PDG_HOT_Americas = new GroupMember(UserOrGroupId = UserContainer[3].id, GroupId = Hot_Americas.Id);
            system.debug('[Test-Class] <PDG_Test_Lead_Routing> GroupMember PDG_Hot_Americas : ' + PDG_Hot_Americas);
            insert PDG_Hot_Americas;
        }
        System.runAs(UserContainer[4]) {
            GroupMember PDG_HOT_EMEA = new GroupMember(UserOrGroupId = UserContainer[4].id, GroupId = Hot_EMEA.Id);
            system.debug('[Test-Class] <PDG_Test_Lead_Routing> GroupMember PDG_HOT_EMEA : ' + PDG_HOT_EMEA);
            insert PDG_HOT_EMEA;
        }
        System.runAs(UserContainer[5]) {
            GroupMember PDG_HOT_APAC = new GroupMember(UserOrGroupId = UserContainer[5].id, GroupId = Hot_APAC.Id);
            system.debug('[Test-Class] <PDG_Test_Lead_Routing> GroupMember PDG_HOT_APAC : ' + PDG_HOT_APAC);
            insert PDG_HOT_APAC;
        }        
        System.runAs(UserContainer[6]) {
            GroupMember PDG_LDR_To_Dx = new GroupMember(UserOrGroupId = UserContainer[6].id, GroupId = RouteDx.Id);
            system.debug('[Test-Class] <PDG_Test_Lead_Routing> GroupMember PDG_LDR_To_Dx : ' + PDG_LDR_To_Dx);
            insert PDG_LDR_To_Dx;
        }
        System.runAs(UserContainer[7]) {
            GroupMember PDG_GROW = new GroupMember(UserOrGroupId = UserContainer[7].id, GroupId = RouteGROW.Id);
            system.debug('[Test-Class] <PDG_Test_Lead_Routing> GroupMember PDG_GROW : ' + PDG_GROW);
            insert PDG_GROW;
        }
        
        cc.SAI_Values__c = 'Applied Genomics, Maternal Fetal Health, Newborn Screening';
        pubGrNames.PDG_HOT_Americas__c = 'PDG Hot Americas';
        pubGrNames.PDG_HOT_EMEA__c = 'PDG Hot EMEA';
        pubGrNames.PDG_HOT_APAC__c = 'PDG Hot APAC';
        pubGrNames.PDG_WARM_Americas__c = 'PDG WARM Americas';
        pubGrNames.PDG_WARM_EMEA__c = 'PDG WARM EMEA';
        pubGrNames.PDG_WARM_APAC__c = 'PDG WARM APAC';
        pubGrNames.PDG_LDR_To_Dx__c = 'PDG LDR To Dx';
        pubGrNames.PDG_GROW_LDRs__c = 'PDG GROW LDRs';
        
        insert cc;
        insert pubGrNames;
        
        for(integer i=0; i<=16; i++){
            Lead LeadRecord = new Lead();
            Contact ConRecord = new Contact();            
            LeadRecord.FirstName = 'TestUser: '+i;
            LeadRecord.LastName  = 'Class: '+i;
            LeadRecord.Title     =  'UnitTest'+i;
            LeadRecord.Street = '225 Blvd';
            LeadRecord.City  = 'Montgomery';
            LeadRecord.Status = 'Open';
            LeadRecord.Country = 'US';  
            LeadRecord.Company = 'Test';
            if(i == 15){
            LeadRecord.OwnerId = '0053A00000DPNX3QAP';
            }
            else{
            LeadRecord.OwnerId = UserContainer[8].id;
            }
            ConRecord.FirstName = 'TestUser: '+i;
            ConRecord.LastName  = 'Class: '+i;
            ConRecord.Title     =  'UnitTest'+i;
            ConRecord.MailingCountry = 'US';
            ConRecord.OwnerId = UserContainer[8].id;
            
            system.debug('[][][] :' + ConRecord.OwnerId);
            
            if(i == 0){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Email = 'usertest-class-'+i+'@test.com';
                LeadRecord.BE__c = 'Dx';
                ConRecord.BU__c = 'Dx';
            }
            else if(i == 1){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Email = 'usertest-class-'+i+'@test.com';
                LeadRecord.Solution_Area_of_Interest__c = 'Applied Genomics';
                ConRecord.Solution_Area_of_Interest__c = 'Applied Genomics';
            }
            else if(i == 2){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Email = 'usertest-class-'+i+'@test.com';
                LeadRecord.Employee_Email__c  = 'usertest-class-'+i+'@test.com';
                OwnerChangeId = UserContainer[2].id;
                system.debug('[][][] line 141: ' + OwnerChangeId);

                //ConRecord.Employee_Email__c  = 'usertest-class-'+i+'@test.com';
            }
            else if(i == 3){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.MailingCountry  = 'AT';

            }
            else if(i == 4){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
            }
            else if(i == 5){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
            }
            else if(i == 6){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
            }
            else if(i == 7){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
                LeadRecord.Qualified_Lead_Hot_Date__c = Date.today() +1;

            }
            else if(i == 8){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.Qualified_Lead_Hot_Date__c = Date.today() +1;

            }
            else if(i == 9){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
                LeadRecord.Employee_Email__c  = 'usertest-class-'+i+'@test.com';
                LeadRecord.Qualified_Lead_Hot_Date__c = Date.today() +1;

            } 
           else if(i == 10){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
				LeadRecord.Eloqua_List_Upload_Date__c = Date.Today();
				ConRecord.Eloqua_List_Upload_Date__c = Date.Today();
		
          } 
       		else if(i == 11){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
			    LeadRecord.Solution_Area_of_Interest__c = 'Applied Genomics';
                ConRecord.Solution_Area_of_Interest__c = 'Applied Genomics';
                LeadRecord.Qualified_Lead_Hot_Date__c = Date.today() +1;
                ConRecord.Qualified_Lead_Hot_Date__c = Date.today() +1;
          } 
            else if(i == 12){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
                LeadRecord.Qualified_Lead_Hot_Date__c = Date.today() +1;
				ConRecord.Qualified_Lead_Hot_Date__c = Date.Today();
            	ConRecord.OwnerId = UserContainer[2].id;
            }
            else if(i == 13){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
            }
            else if(i == 14){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
           	    LeadRecord.Country = 'AT';  
                ConRecord.Email = 'usertest-class-'+i+'@test.com';
                ConRecord.Converted_QL__c = 'true';
            }  
            else if(i == 15){
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
           	    LeadRecord.Country = 'AT';  
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
                ConRecord.Converted_QL__c = 'true';
            }
            else if(i == 16){
            	LeadRecord.OwnerId = UserContainer[7].id;
                LeadRecord.Qualified_Lead_Hot_Date__c = Date.today();
                LeadRecord.Email = 'usertest-class-'+i+'@test.com'; 
           	    LeadRecord.Country = 'AT';  
                ConRecord.Email = 'usertest-class-'+i+'@test.com'; 
            }              
            LeadContainer.add(LeadRecord);
            ConContainer.add(ConRecord);            
        }        
        Insert LeadContainer;
        PDG_Routing_Class.is_First = true;
        multi_Interaction_logic.is_First = true;
        Insert ConContainer;
        PDG_Routing_Class.is_First = true;
        multi_Interaction_logic.is_First = true;
    }
     
    
    
    @isTest static void Route_Lead(){
        
        List <Lead> Container = new List <Lead>();
        List <Contact> ConContainer = new List <Contact>();
        
        List <id> Container_Test = new List <id>();
        List <id> Container_Test2 = new List <id>();
        
        
        map <id, Lead> LeadMap =  new map <id, Lead>([
            Select Id,FirstName,ManagerEmail__c, Description, Qualified_Lead_Warm_Date__c, Status_Chemicals__c, Qualified_Lead_Hot_Date__c, BE__c, Title, Email, Name, Ownerid, Country, Solution_Area_Of_Interest__c From Lead Where Title like '%Unit%' ORDER BY Title]);   
        
        map <id, Contact> ConMap =  new map <id, Contact>([
            Select Id,FirstName, Converted_QL__c,ConvertedRecordId__c, Description, Qualified_Lead_Warm_Date__c, Status_Chemicals__c, Qualified_Lead_Hot_Date__c, BU__c, Title, Email, Name, Ownerid, Country__c, Solution_Area_Of_Interest__c From Contact Where Title like '%Unit%' ORDER BY Title]);   
        
        
        for(Lead Record : LeadMap.values()){
            if(Record.title == 'UnitTest0'){
                Record.Qualified_Lead_Warm_Date__c = Date.today() + 1;
            }
            if(Record.title == 'UnitTest1'){
                Record.Qualified_Lead_Hot_Date__c = Date.today() + 1;
 				Record.Country  = 'JP'; 
                Record.Status_Chemicals__c = 'Working';
            }
            if(Record.title == 'UnitTest2'){
                Record.Qualified_Lead_Hot_Date__c = Date.today() + 1;
                Record.Country  = 'AT';
            }
            if(Record.title == 'UnitTest3'){
                Record.Qualified_Lead_Warm_Date__c = Date.today() + 1;
                
            }
            if(Record.title == 'UnitTest4'){
                Record.Qualified_Lead_Warm_Date__c = Date.today() + 1;
                Record.Country = 'AT';
                Record.Status_Chemicals__c = 'Working';

            }
            if(Record.title == 'UnitTest5'){
                Record.Qualified_Lead_Warm_Date__c = Date.today() + 1;
                Record.Country = 'JP';
            }
            if(Record.title == 'UnitTest6'){
                Record.Qualified_Lead_Hot_Date__c = Date.today() + 1;
            }
            if(Record.title == 'UnitTest7'){
                Record.Qualified_Lead_Hot_Date__c = Date.today() + 1;
                Record.Country = 'AT';
            }
            if(Record.title == 'UnitTest8'){
                Record.Qualified_Lead_Hot_Date__c = Date.today() + 1;
                Record.Country = 'JP';
            }
            if(Record.title == 'UnitTest9'){
                Record.Eloqua_List_Upload_Date__c = Date.today() + 1;
            }
            if(Record.title == 'UnitTest10'){
                Record.Eloqua_List_Upload_Date__c = Date.today() + 2;
            } 
            if(Record.title == 'UnitTest11'){
                Record.Eloqua_List_Upload_Date__c = Date.today() + 2;
                OwnerChangeId = Record.OwnerId;
            } 
            if(Record.title == 'UnitTest12'){
                Record.OwnerId = OwnerChangeId;
            }
            if(Record.title == 'UnitTest13'){
                Record.OwnerId = OwnerChangeId;
                Record.Status_Chemicals__c = 'Working';
               // system.debug('[][][]Owner user: ' + OwnerChangeId);
            } 
            if(Record.title == 'UnitTest14'){
                Record.Qualified_Lead_Hot_Date__c = Date.today()+1;
               system.debug('[][][]Hot: ' + Record.Qualified_Lead_Warm_Date__c);
            }
            if(Record.title == 'UnitTest16'){
                Record.OwnerId = OwnerChangeId;
            }            



            Container.add(Record);
            Container_Test.add(Record.id);    
        }
        
        for(Contact Record : ConMap.values()){
            if(Record.title == 'UnitTest0'){
                Record.Qualified_Lead_Warm_Date__c = Date.today() + 1;
            }
            if(Record.title == 'UnitTest1'){
                Record.Qualified_Lead_Warm_Date__c = Date.today() + 1;
            }
            if(Record.title == 'UnitTest2'){
                Record.Qualified_Lead_Warm_Date__c = Date.today() + 1;
                Record.MailingCountry  = 'US';
                Record.Status_Chemicals__c = 'Working';
            }
            if(Record.title == 'UnitTest3'){
                Record.Qualified_Lead_Warm_Date__c = Date.today();
                Record.MailingCountry  = 'AT';
            }
            if(Record.title == 'UnitTest4'){
                Record.Qualified_Lead_Warm_Date__c = Date.today();
                Record.MailingCountry  = 'JP';
            }
            if(Record.title == 'UnitTest5'){
                Record.Qualified_Lead_Hot_Date__c = Date.today();
                Record.MailingCountry  = 'US';
                Record.Status_Chemicals__c = 'Working';
            }
            if(Record.title == 'UnitTest6'){
                Record.Qualified_Lead_Hot_Date__c = Date.today();
                Record.MailingCountry  = 'AT';
            }
            if(Record.title == 'UnitTest7'){
                Record.Qualified_Lead_Hot_Date__c = Date.today();
                Record.MailingCountry = 'JP';
                OwnerChangeId = Record.OwnerId;
            }
            if(Record.title == 'UnitTest9'){
                Record.Eloqua_List_Upload_Date__c = Date.today() + 1;
            }
            if(Record.title == 'UnitTest10'){
                Record.Eloqua_List_Upload_Date__c = Date.today() + 2;
            } 
            if(Record.title == 'UnitTest12'){
			 Record.OwnerId = OwnerChangeId;
   			 Record.MailingCountry = 'JP';
            }            
             
            if(Record.title == 'UnitTest13'){
               // Record.ConvertedRecordId__c;
                Record.Converted_QL__c = 'true';
                Record.Qualified_Lead_Hot_Date__c = Date.today() - 1;
                //system.debug('[][][]-Owner user: ' + Record.Ownerid + ' - ' + Record.Qualified_Lead_Hot_Date__c);
            } 
            if(Record.title == 'UnitTest14'){
               // Record.ConvertedRecordId__c;
                Record.Converted_QL__c = 'true';
                //system.debug('[][][]-Owner user: ' + Record.Ownerid + ' - ' + Record.Qualified_Lead_Hot_Date__c);
            }                
            
            ConContainer.add(Record);
            Container_Test2.add(Record.id);    
        }


        update Container; 
        PDG_Routing_Class.is_First = true;
        multi_Interaction_logic.is_First = true;

        update ConContainer; 
		PDG_Routing_Class.is_First = true;
        multi_Interaction_logic.is_First = true; 
        
        
        
         List <Contact> ConContainer2 = new List <Contact>();
        
        
        map <id, Contact> ConMap2 =  new map <id, Contact>([
            Select Id,FirstName,Description, Qualified_Lead_Warm_Date__c, Status_Chemicals__c, Qualified_Lead_Hot_Date__c, BU__c, Title, Email, Name, Ownerid, Country__c, Solution_Area_Of_Interest__c From Contact Where Title like '%Unit%' ORDER BY Title DESC]);   
        
        for(Contact Record : ConMap2.values()){
            // system.debug('[][][]Owner user: ' + Record.OwnerId + ' -- ' + Record.title + ' = ' + Record.Qualified_Lead_Hot_Date__c);
            if(Record.title == 'UnitTest8'){
                Record.MailingCountry = 'JP';
                OwnerChangeId = Record.OwnerId;
            }
          
            if(Record.title == 'UnitTest12'){
                Record.OwnerId = OwnerChangeId;
                system.debug('[][][] == Owner user: ' + OwnerChangeId + ' - ' + Record.Qualified_Lead_Hot_Date__c);
            }                         
            ConContainer2.add(Record);
        }
    	update ConContainer2; 
        PDG_Routing_Class.is_First = true;
        multi_Interaction_logic.is_First = true;        

      //  ConstructTestScenerios(Container, Container_Test);
        ConstructTestScenerios2(ConContainer, Container_Test2);
        
      
        
    }
    
       
    @isTest static void Route_Contact(){
        
        List <Contact> ConContainer = new List <Contact>();
        
        List <id> Container_Test = new List <id>();
        
        map <id, Contact> ConMap =  new map <id, Contact>([
            Select Id,FirstName,Description, Qualified_Lead_Warm_Date__c, Status_Chemicals__c, Qualified_Lead_Hot_Date__c, BU__c, Title, Email, Name, Ownerid, Country__c, Solution_Area_Of_Interest__c From Contact Where Title like '%Unit%' ORDER BY Title DESC]);   
        
        for(Contact Record : ConMap.values()){
            // system.debug('[][][]Owner user: ' + Record.OwnerId + ' -- ' + Record.title + ' = ' + Record.Qualified_Lead_Hot_Date__c);
            if(Record.title == 'UnitTest8'){
                Record.MailingCountry = 'JP';
                OwnerChangeId = Record.OwnerId;
            }
          
            if(Record.title == 'UnitTest12'){
                Record.OwnerId = OwnerChangeId;
                system.debug('[][][] == Owner user: ' + OwnerChangeId + ' - ' + Record.Qualified_Lead_Hot_Date__c);
            }                         
            ConContainer.add(Record);
        }
    	update ConContainer; 
        PDG_Routing_Class.is_First = true;
        multi_Interaction_logic.is_First = true;        
    }
    
    static void ConstructTestScenerios(List <Lead> Container, List <id> Container_Test){
        List <Lead> Current = [select id, FirstName, ownerid from lead where id in:Container_Test];
        for(Lead a : Current){
            if(a.FirstName == 'TestUser: 0'){
                BE_equals_Dx(a, Container[0].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[0].ownerid);
            }
            if(a.FirstName == 'TestUser: 1'){
                 Routes_To_Dx(a, Container[1].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[1].ownerid);
            }
            if(a.FirstName == 'TestUser: 2'){
                Routes_To_GROW(a, Container[2].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[2].ownerid);
            }
            if(a.FirstName == 'TestUser: 3'){
                Warm_Routes_To_Americas(a, Container[3].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[3].ownerid);
            }
            if(a.FirstName == 'TestUser: 4'){
                Warm_Routes_To_EMEA(a, Container[4].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[4].ownerid);
            } 
            if(a.FirstName == 'TestUser: 5'){
                Warm_Routes_To_APAC(a, Container[5].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[5].ownerid);
            }
            if(a.FirstName == 'TestUser: 6'){
                Hot_Routes_To_Americas(a, Container[6].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[6].ownerid);
            }
            if(a.FirstName == 'TestUser: 7'){
               Hot_Routes_To_EMEA(a, Container[7].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[7].ownerid);
            } 
            if(a.FirstName == 'TestUser: 8'){
                Hot_Routes_To_APAC(a, Container[8].ownerid);
                system.debug(a.OwnerId + ' : ' + Container[8].ownerid);
            } 
        }
    }

    
       static void ConstructTestScenerios2(List <Contact> ConContainer, List <id> Container_Test2){
        List <Contact> Current = [select id, FirstName, ownerid from Contact where id in:Container_Test2];
        for(Contact a : Current){
            if(a.FirstName == 'TestUser: 0'){
                BE_equals_DxCo(a, ConContainer[0].ownerid);
                system.debug(a.OwnerId + ' : ' + ConContainer[0].ownerid);
            }
            if(a.FirstName == 'TestUser: 1'){
                Routes_To_DxCo(a, ConContainer[1].ownerid);
                system.debug(a.OwnerId + ' : ' + ConContainer[1].ownerid);
            }
            if(a.FirstName == 'TestUser: 2'){
                Warm_Routes_To_AmericasCo(a, ConContainer[2].ownerid);
                system.debug(a.OwnerId + ' : ' + ConContainer[2].ownerid);
            }
            if(a.FirstName == 'TestUser: 3'){
                Warm_Routes_To_EMEACo(a, ConContainer[3].ownerid);
                system.debug(a.OwnerId + ' : ' + ConContainer[3].ownerid);
            } 
            if(a.FirstName == 'TestUser: 4'){
                Warm_Routes_To_APACCo(a, ConContainer[4].ownerid);
                system.debug(a.OwnerId + ' : ' + ConContainer[4].ownerid);
            }
            if(a.FirstName == 'TestUser: 5'){
                Hot_Routes_To_AmericasCo(a, ConContainer[5].ownerid);
                system.debug(a.OwnerId + ' : ' + ConContainer[5].ownerid);
            }
            if(a.FirstName == 'TestUser: 6'){
                Hot_Routes_To_EMEACo(a, ConContainer[6].ownerid);
                system.debug(a.OwnerId + ' : ' + ConContainer[6].ownerid);
            } 
            if(a.FirstName == 'TestUser: 7'){
                Hot_Routes_To_APACCo(a, ConContainer[7].ownerid);
                system.debug(a.OwnerId + ' : ' + ConContainer[7].ownerid);
            } 
        }
    }
    
    static void BE_equals_Dx(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 0 Dx Record, Owner shouldnt change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId == DefaultOwner, 'Lead 0 DX Owner changed. Expected : ' + DefaultOwner);
    }
    static void Routes_To_Dx(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 1 SAI Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Lead 1 SAI Owner did not change');
    }
    static void Routes_To_GROW(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 2 GROW Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Lead 2 Owner did not change');  
    }
    static void Warm_Routes_To_Americas(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 3 WARM Americas Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Lead 3 WARM Americas Owner did not change');  
    }
    static void Warm_Routes_To_EMEA(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 4 WARM EMEA Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Lead 4 WARM EMEA Owner did not change');  
    }
    static void Warm_Routes_To_APAC(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 5 WARM APAC Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Lead 5 WARM APAC Owner did not change');  
        
    }
    static void Hot_Routes_To_Americas(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 6 HOT Americas Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Lead 6 HOT Americas Owner did not change');  
    }
    static void Hot_Routes_To_EMEA(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 7 HOT EMEA Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        //system.assert(Record.OwnerId != DefaultOwner, 'Lead 7 HOT EMEA Owner did not change');  
    }
    static void Hot_Routes_To_APAC(Lead Record, ID DefaultOwner){
        system.debug('*** Lead 8 HOT APAC Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Lead 8 HOT APAC Owner did not change');  
        
    }
    
    // CONTACTS
    
	static void BE_equals_DxCo(Contact Record, ID DefaultOwner){
        system.debug('*** Con 0 Dx Record, Owner shouldnt change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId == DefaultOwner, 'Con 0 DX Owner changed. Expected : ' + DefaultOwner);
    }
    static void Routes_To_DxCo(Contact Record, ID DefaultOwner){
        system.debug('*** Con 1 SAI Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Con 1 SAI Owner did not change');
    }
    static void Warm_Routes_To_AmericasCo(Contact Record, ID DefaultOwner){
        system.debug('*** Con 2 WARM Americas Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Con 2 WARM Americas Owner did not change');  
    }
    static void Warm_Routes_To_EMEACo(Contact Record, ID DefaultOwner){
        system.debug('*** Con 3 WARM EMEA Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Con 3 WARM EMEA Owner did not change');  
    }
    static void Warm_Routes_To_APACCo(Contact Record, ID DefaultOwner){
        system.debug('*** Con 4 WARM APAC Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Con 4 WARM APAC Owner did not change');  
        
    }
    static void Hot_Routes_To_AmericasCo(Contact Record, ID DefaultOwner){
        system.debug('*** Con 5 HOT Americas Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Con 5 HOT Americas Owner did not change');  
    }
    static void Hot_Routes_To_EMEACo(Contact Record, ID DefaultOwner){
        system.debug('*** Con 6 HOT EMEA Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Con 6 HOT EMEA Owner did not change');  
    }
    static void Hot_Routes_To_APACCo(Contact Record, ID DefaultOwner){
        system.debug('*** Con 7 HOT APAC Record, Owner should change: ' + Record.OwnerId +': Previous Owner - '+ DefaultOwner);         
        system.assert(Record.OwnerId != DefaultOwner, 'Con 7 HOT APAC Owner did not change');  
        
    }
}