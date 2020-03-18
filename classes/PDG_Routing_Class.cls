public class PDG_Routing_Class{
    /*
Purpose for this class:
This class is designed to be a handler class for
PDG program. Leads and contacts will be passed to 
this class to cycle through various conditions and 
then passed on to the PDG Assign Lead class or the 
PDG Assign Contact class for routing.

Developed by ANNUITAS
*/
    
    // Lead data types
    List<Lead> newList;
    map<id,Lead> oldList;
    List<Lead> storedList = new List <Lead>();
    List<Lead> LDRtoDx = new List <Lead>();
    List<Lead> GROW_LDR = new List <Lead>();
    List<Lead> QL_Warm_Leads = new List <Lead>();
    List<Lead> QL_Hot_Leads = new List <Lead>();
    List<Lead> Digital_Lab_Leads = new List <Lead>();
    List<Lead> BE_Informatics = new List <Lead>();
    Map <id,Lead> StatusChanged_Store_Leads = new Map <id,Lead>();
    // Contact data types
    List<Contact> newList_Contact;
    map<id,Contact> oldList_Contact;
    List<Contact> storedList_Contact = new List <Contact>();
    List<Contact> LDRtoDx_Contact = new List <Contact>();
    List<Contact> GROW_LDR_Contact = new List <Contact>();
    List<Contact> QL_Warm_Contacts = new List <Contact>();
    List<Contact> QL_Hot_Contacts = new List <Contact>();
    List<Contact> Digital_Lab_Contact = new List <Contact>();
    List<Contact> BE_Informatics_Contact = new List <Contact>();
    Map <id,Contact> StatusChanged_Store_Leads_C = new Map <id,Contact>();
    map<string,Contact> ListForStatusTracking = new map <string,Contact>();
    
    
    // Generic Data Types
    SAI_Lead_Routing_Values__c mc = SAI_Lead_Routing_Values__c.getInstance();
    String ac = mc.SAI_Values__c; 
    PDG_Queue__c pdg = PDG_Queue__c.getInstance();
    String[] SAI = null; 
    public static boolean is_First = true;
    public static boolean is_Firstb = true;
    public static String GROW_string = '/servlet/servlet.FileDownload?file=0153A000004RF8J';
    
    public PDG_Routing_Class(List<Lead> New_Leads, map<id,Lead> Old_Leads){
        newList = New_Leads; 
        oldList = Old_Leads; 
        if(ac!=null)
            SAI = ac.split(',');
    }
    
    public PDG_Routing_Class(List<Contact> New_Contacts, map<id,Contact> Old_Contacts){
        newList_Contact = New_Contacts; 
        oldList_Contact = Old_Contacts; 
        if(ac!=null)
            SAI = ac.split(',');
    }
    
    public void Lead_Records() { 
        for(Lead a : newList){
            a.Just_Converted__c = 'true'; // for SAI Tracking
            if(Trigger.isUpdate){
                StatusChanged_Store_Leads.put(a.id, a);
               // a.ConvertedRecordId__c = a.id; // for SAI Tracking
                a.Just_Converted__c = 'true'; // for SAI Tracking
                if(a.Warm_Date_Only__c != oldList.get(a.id).Warm_Date_Only__c && a.PDG_Does_Warm_Record_Route__c && !string.isEmpty(a.Lead_Owner_LDR_QL__c) || a.Hot_Date_Only__c != oldList.get(a.id).Hot_Date_Only__c && a.PDG_Does_Hot_Record_Route__c && !string.isEmpty(a.Lead_Owner_LDR_QL__c)){
                    a.First_Owner_Changed__c ='';
                    a.Is_PDG_Routing__c = false; //miss routing fix
                    a.PDG_Start_Time__c = null;
                    a.PDG_Routing_Tracking__c = '';
                    a.missedRouting__c = false; 
                    a.Alert_First_Owner_Email__c = false;
                    system.debug('[Class] <PDG_Routing> Possible Requalified: ' + a.id);
                }
            }
            
            Boolean is_Routable = (a.PDG_Does_Warm_Record_Route__c && a.First_Owner_Changed__c != 'Yes' || a.PDG_Does_Hot_Record_Route__c && a.First_Owner_Changed__c != 'Yes') ? True : False;
            if(!a.Is_PDG_Routing__c){ //miss routing fix
                Boolean is_ExistingRecord = (oldList != null) ? True : False ;
                system.debug('[Class] <PDG_Routing> Record : ' + a);
                system.debug('[Class] <PDG_Routing> is Routable : ' + is_Routable);
                system.debug('[Class] <PDG_Routing> is_Dx__c : ' + a.Is_Dx__c);
                
                if(a.Assign_to_PDG_Queue__c && userinfo.getuserid() == '0053A00000DPNX3QAP'){ //Eloqua Service Account Id
                    if(Trigger.isInsert){
                        a.OwnerId = pdg.PDG_Lead_Queue__c;
                        a.PDG_Routing_Tracking__c = 'Should be PDG Queue!' + String.valueOf(Datetime.now()) + '_';
                    }
                }
                else{
                    if(string.isEmpty(a.PDG_Routing_Tracking__c) && is_Routable){
                        if(a.Did_Trigger_Run__c == 'Yes (Insert)'){
                            a.PDG_Routing_Tracking__c = '*Insert_';
                        } else if (a.Did_Trigger_Run__c == 'Yes (Update)'){
                            a.PDG_Routing_Tracking__c = '*Update_';
                        }
                    }
                    
                    if(is_Routable && is_ExistingRecord == false){
                        a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'Starting_'+ String.valueOf(Datetime.now()) + '_' + is_Routable + '_New Record';
                        
                        if(!SAI.Contains(a.Solution_Area_of_Interest__c)){
                            if(!string.isEmpty(a.GROW__c) && a.GROW__c.Contains(GROW_string)){ // For GROW Leads
                                a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c  + 'GW_';
                                GROW_LDR.add(a);
                            }
                            else{
                                a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'NR_';
                                storedList.add(a);
                                system.debug('[Class] <PDG_Routing> Routable : ' + is_Routable);
                            }
                        } 
                        else{
                            // Send to LDR who manually routes to DX
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'DX_';
                            LDRtoDx.add(a);  
                            system.debug('[Class] <PDG_Routing> Routes to DX : ' + is_Routable);
                        }
                        system.debug('[Class] <PDG_Routing> new record is Routable : ' + is_Routable);
                        
                        
                    }
                    else if(is_Routable && is_ExistingRecord == true){
                        Boolean Is_Date_Different = (a.Warm_Date_Only__c != oldList.get(a.id).Warm_Date_Only__c || a.Hot_Date_Only__c != oldList.get(a.id).Hot_Date_Only__c) ? True : False;
                        if(Is_Date_Different){
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + '_' + String.valueOf(Datetime.now()) + '_';
                            if(!SAI.Contains(a.Solution_Area_of_Interest__c)){
                                if(!string.isEmpty(a.GROW__c) && a.GROW__c.Contains(GROW_string)){ // For GROW Leads
                                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'GW_';
                                    GROW_LDR.add(a);
                                    system.debug('[Class] <PDG_Routing> Existing record is Routable : ' + is_Routable);
                                }
                                else{
                                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'NR_';
                                    storedList.add(a);
                                    system.debug('[Class] <PDG_Routing> Routable : ' + is_Routable);
                                }
                            } 
                            else{
                                // Send to LDR who manually routes to DX
                                a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'DX_';
                                LDRtoDx.add(a);  
                                system.debug('[Class] <PDG_Routing> Routes to DX : ' + is_Routable);
                            }   
                            system.debug('[Class] <PDG_Routing> Existing record is Routable : ' + is_Routable);
                        }
                        system.debug('[Class] <PDG_Routing> Dates are different : ' + Is_Date_Different);
                        
                    }
                }
            } //miss routing fix
            
            if(Trigger.isUpdate){
                if(a.OwnerId != oldList.get(a.id).OwnerId && !SAI.Contains(a.Solution_Area_of_Interest__c) && (a.PDG_Does_Warm_Record_Route__c || a.PDG_Does_Hot_Record_Route__c)){
                    a.First_Owner_Changed__c ='Yes';
                    system.debug('[Class] <PDG_Routing> Owner Changed : Yes' + ' = ' + a.OwnerId + ' : ' + oldList.get(a.id).OwnerId);
                    
                    if(a.ManagerEmail__c == null){
                        a.Lead_Manager_Email__c = 'Toby.OConnor@PERKINELMER.COM';
                        system.debug('A - ManagerEmail__c ='+ a.ManagerEmail__c);
                    } else{
                        a.Lead_Manager_Email__c = a.ManagerEmail__c;
                        system.debug('B - ManagerEmail__c ='+ a.ManagerEmail__c);
                    }                    
                    
                    if(a.PDG_Start_Time__c == null && a.Dispensation_SAI_Current_Status__c){
                        a.PDG_Start_Time__c = DateTime.now();
                        system.debug('[Class] <PDG_Routing> Time updated : ' + a.PDG_Start_Time__c);
                    }
                    
                }
            }
            
            
            // Leads missed routing - send out email
            if(is_Routable && a.missedRouting__c == false && (string.isEmpty(a.PDG_Routing_Tracking__c) || a.PDG_Routing_Tracking__c == '*Insert_' || a.PDG_Routing_Tracking__c == '*Update_')){
                a.missedRouting__c = true;
                a.PDG_Routing_Tracking__c =  a.PDG_Routing_Tracking__c + '_' + String.valueOf(Datetime.now()) + '_';
            }
        }
        
        // Call LDR_To_Dx Method
        if(LDRtoDx.size() > 0) PDG_Assign_Lead.LDR_To_Dx(LDRtoDx);
        
        // Call GROW_LDR Method
        if(GROW_LDR.size() > 0) PDG_Assign_Lead.GROW_LDR(GROW_LDR);
        
        // Call RecordEvaluation_Part2 Method
        if(storedList.size() > 0) RecordEvaluation_Part2(storedList);
        
        // Call Status Change Check
        if(trigger.isUpdate){
            PKI_SAI_Status_Tracking_handler.CheckStatus(StatusChanged_Store_Leads, oldList);
        }
        
    }
    
    // Record Evaluation Part 2 Method
    public void RecordEvaluation_Part2(List <Lead> RecordPart2){
        system.debug('[Class] <PDG_Routing> **Starting Part 2**');   
        for(Lead a : RecordPart2){
            String WarmOrHot = (a.PDG_Does_Warm_Record_Route__c == true) ? 'Warm' : 'Hot';
            switch on WarmOrHot{
                when 'Warm'{
                    // Send to QL_Warm Method 
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'W_';
                    QL_Warm_Leads.add(a); 
                    system.debug('[Class] <PDG_Routing> **Warm**');
                }
                when 'Hot'{
                    // Send to QL_Hot Method 
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'H_';
                    QL_Hot_Leads.add(a); 
                    system.debug('[Class] <PDG_Routing> **Hot**');
                }
                
            }
            
            
        }  
        
        // Call QL_Warm Method
        if(QL_Warm_Leads.size() > 0) QL_Warm(QL_Warm_Leads);
        
        // Call QL_Hot Method
        if(QL_Hot_Leads.size() > 0) QL_Hot(QL_Hot_Leads);  
    }
    
    
    
    
    // Route to QL Warm Method
    public static void QL_Warm(List <Lead> Le){
        map <String,List<Lead>> Records = new map <String,List<Lead>>();
        List<Lead> americaLeads = new List<Lead>();
        List<Lead> emeaLeads = new List<Lead>();
        List<Lead> apacLeads = new List<Lead>();
        
        for(Lead a : Le){
            switch on a.Global_Region__c{
                when 'Americas','None','Other'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **Americas or None**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'A_';
                    americaLeads.add(a);
                }
                when 'EMEA'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **EMEA**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'E_';
                    emeaLeads.add(a);
                }
                when 'APAC'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **APAC**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'AP_';
                    apacLeads.add(a);
                }
            }
        }
        Records.put('Americas',americaLeads);
        Records.put('EMEA',emeaLeads);
        Records.put('APAC',apacLeads);
        if(Records.size() > 0) PDG_Assign_Lead.WarmRecords(Records);       
    }
    
    // Route to QL Hot Method
    public static void QL_Hot(List <Lead> Le){
        map <String,List<Lead>> Records = new map <String,List<Lead>>();
        List<Lead> americaLeads = new List<Lead>();
        List<Lead> emeaLeads = new List<Lead>();
        List<Lead> apacLeads = new List<Lead>();
        
        for(Lead a : Le){
            switch on a.Global_Region__c{
                when 'Americas','None','Other'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **Americas or None**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'A_';
                    americaLeads.add(a);
                }
                when 'EMEA'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **EMEA**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'E_';
                    emeaLeads.add(a);
                }
                when 'APAC'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **APAC**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'AP_';
                    apacLeads.add(a);
                }
            }
        }  
        Records.put('Americas',americaLeads);
        Records.put('EMEA',emeaLeads);
        Records.put('APAC',apacLeads);
        if(Records.size() > 0) PDG_Assign_Lead.HotRecords(Records);       
        system.debug('*%%getCpuTime()***'+Limits.getCpuTime());
        
        
    }
    
    
    // Contact Routes  
    public void Contact_Records() {
        system.debug(SAI);
        for(Contact a : newList_Contact){
            if(Trigger.isInsert && Trigger.isAfter){
                if(a.Converted_QL__c == 'true' && !string.isBlank(a.StoreConvertedRecordID__c)){
                    ListForStatusTracking.put(a.StoreConvertedRecordID__c, a);
                }
            }
            else if(Trigger.isUpdate){
                if(a.Warm_Date_Only__c != oldList_Contact.get(a.id).Warm_Date_Only__c && a.PDG_Does_Warm_Record_Route__c && !string.isEmpty(a.Lead_Owner_LDR_QL__c) || a.Hot_Date_Only__c != oldList_Contact.get(a.id).Hot_Date_Only__c && a.PDG_Does_Hot_Record_Route__c && !string.isEmpty(a.Lead_Owner_LDR_QL__c)){
                    a.First_Owner_Changed__c ='';
                    a.PDG_Start_Time__c = null;
                    a.PDG_Routing_Tracking__c = '';
                    a.Is_PDG_Routing__c = false;//miss routing fix
                    a.missedRouting__c = false;
                    a.Alert_First_Owner_Email__c = false;
                    system.debug('[Class] <PDG_Routing> Possible Requalified: ' + a.id);
                }          
            }
            
            Boolean is_Routable = (a.PDG_Does_Warm_Record_Route__c && a.First_Owner_Changed__c != 'Yes' || a.PDG_Does_Hot_Record_Route__c && a.First_Owner_Changed__c != 'Yes') ? True : False;
            system.debug('[Class] <PDG_Routing> Record : ' + a);
            system.debug('[Class] <PDG_Routing> is Routable : ' + is_Routable);
            system.debug('[Class] <PDG_Routing> is_Dx__c : ' + a.Is_Dx__c);
            
            if(string.isEmpty(a.PDG_Routing_Tracking__c) && Trigger.isBefore){
                a.PDG_Routing_Tracking__c = '*Starting_' + String.valueOf(Datetime.now()) + '_' + is_Routable + '_';
            }
            
            if(Trigger.isUpdate && Trigger.isBefore){
                // Check status of Converted QL
                // 
                if(a.Has_Opportunity__c){
                    a.Has_Opportunity__c = false;
                }
                else if(a.Converted_QL__c == 'true' && !string.isBlank(a.StoreConvertedRecordID__c) || string.isBlank(a.Converted_QL__c) && !string.isBlank(a.StoreConvertedRecordID__c)){
                    a.Converted_QL__c='';
                    ListForStatusTracking.put(a.StoreConvertedRecordID__c, a);
                }
                else if(a.Converted_QL__c == 'false' && !string.isBlank(a.StoreConvertedRecordID__c)){
                    a.Converted_QL__c='';
                    a.StoreConvertedRecordID__c = null; 
                    a.ConversionFromLead__c = true;
                    
                }
                else if(is_Routable && (a.Converted_QL__c != 'true') && !a.Is_PDG_Routing__c ){
                    Boolean Is_Date_Different = (a.Warm_Date_Only__c != oldList_Contact.get(a.id).Warm_Date_Only__c || a.Hot_Date_Only__c != oldList_Contact.get(a.id).Hot_Date_Only__c ) ? True : False;
                    a.ConversionFromLead__c = false;
                    if(Is_Date_Different){
                        a.First_Owner_Changed__c = '';
                        StatusChanged_Store_Leads_C.put(a.id, a);
                        
                        if(!SAI.Contains(a.Solution_Area_of_Interest__c)){
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'NR_';
                            storedList_Contact.add(a);
                            system.debug('[Class] <PDG_Routing> Record added to List : ' + a.FirstName);                       
                            
                        } 
                        else{
                            // Send to LDR who manually routes to DX
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'DX_';
                            LDRtoDx_Contact.add(a);  
                            system.debug('[Class] <PDG_Routing> Routes to DX : ' + is_Routable);
                        }
                        system.debug('[Class] <PDG_Routing> Existing record is Routable : ' + is_Routable);
                    }
                    StatusChanged_Store_Leads_C.put(a.id, a);
                    system.debug('[Class] <PDG_Routing> Dates are different : ' + Is_Date_Different);
                }
                else{
                    StatusChanged_Store_Leads_C.put(a.id, a);
                }
            system.debug('oldList'+a.id+a.Solution_Area_of_Interest__c+a.PDG_Does_Warm_Record_Route__c+a.PDG_Does_Hot_Record_Route__c);
               if(a.OwnerId != oldList_Contact.get(a.id).OwnerId && !SAI.Contains(a.Solution_Area_of_Interest__c) && (a.PDG_Does_Warm_Record_Route__c || a.PDG_Does_Hot_Record_Route__c)){
                    a.First_Owner_Changed__c ='Yes';
                    system.debug('[Class] <PDG_Routing> Owner Changed : Yes' + ' = ' + a.OwnerId + ' : ' + oldList_Contact.get(a.id).OwnerId);
                    
                    if(a.ManagerEmail__c == null){
                        a.Contact_Manager_Email__c = 'Toby.OConnor@PERKINELMER.COM';
                    } else{
                        a.Contact_Manager_Email__c = a.ManagerEmail__c;
                    }                          
                    if(a.PDG_Start_Time__c == null && a.Dispensation_SAI_Current_Status__c){
                        a.PDG_Start_Time__c = DateTime.now();
                        system.debug('[Class] <PDG_Routing> Time updated : ' + a.PDG_Start_Time__c);
                    }
                    
                }
                
            }
            // Contacts missed routing - send out email
            if(Trigger.isBefore && is_Routable && a.missedRouting__c == false && (string.isEmpty(a.PDG_Routing_Tracking__c) || a.PDG_Routing_Tracking__c == '*Starting_true_')){
                a.missedRouting__c = true;
                a.PDG_Routing_Tracking__c =  a.PDG_Routing_Tracking__c + '_' + String.valueOf(Datetime.now());
            }
        }
        // Call LDR_To_Dx Method
        if(LDRtoDx_Contact.size() > 0) PDG_Assign_Contact.LDR_To_Dx(LDRtoDx_Contact);
        
        // Call RecordEvaluation_Part2 Method
        if(storedList_Contact.size() > 0) RecordEvaluation_Part2(storedList_Contact);
        
        // Call Status Change Check
        if(trigger.isUpdate){
            PKI_SAI_Status_Tracking_handler.CheckStatus_C(StatusChanged_Store_Leads_C, oldList_Contact);
        }
        
        
        // Call Status Change Update for Contacts Related List
        if(ListForStatusTracking.size()>0){
            system.debug('[][][]First : WE ARE HERE!!!!');
            PKI_SAI_Status_Tracking_handler.UpdateContactRelatedList(ListForStatusTracking);    
        }
        
        //  }
    }
    
    // Record Evaluation Part 2 Method
    public void RecordEvaluation_Part2(List <Contact> RecordPart2){
        system.debug('[Class] <PDG_Routing> **Starting Part 2**');   
        for(Contact a : RecordPart2){
            String WarmOrHot = (a.PDG_Does_Warm_Record_Route__c == true) ? 'Warm' : 'Hot';
            
            switch on WarmOrHot{
                when 'Warm'{
                    // Send to QL_Warm Method 
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'W_';
                    QL_Warm_Contacts.add(a); 
                    system.debug('[Class] <PDG_Routing> **Warm**');
                }
                when 'Hot'{
                    // Send to QL_Hot Method 
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'H_';
                    QL_Hot_Contacts.add(a); 
                    system.debug('[Class] <PDG_Routing> **Hot**');
                }
            }
            
        }  
        
        // Call QL_Warm Method
        if(QL_Warm_Contacts.size() > 0) QL_Warm(QL_Warm_Contacts);
        
        // Call QL_Hot Method
        if(QL_Hot_Contacts.size() > 0) QL_Hot(QL_Hot_Contacts);  
        
    }
    
    
    // Route to QL Warm Method
    public static void QL_Warm(List <Contact> Le){
        map <String,List<Contact>> Records = new map <String,List<Contact>>();
        List<Contact> americaContacts = new List<Contact>();
        List<Contact> emeaContacts = new List<Contact>();
        List<Contact> apacContacts = new List<Contact>();
        
        for(Contact a : Le){
            switch on a.Global_Region__c{
                when 'Americas','None','Other'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **Americas or None**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'A_';
                    americaContacts.add(a);
                }
                when 'EMEA'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **EMEA**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'E_';
                    emeaContacts.add(a);
                }
                when 'APAC'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **APAC**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'AP_';
                    apacContacts.add(a);
                }
            }
        }
        Records.put('Americas',americaContacts);
        Records.put('EMEA',emeaContacts);
        Records.put('APAC',apacContacts);
        if(Records.size() > 0) PDG_Assign_Contact.WarmRecords(Records);       
    }
    
    // Route to QL Hot Method
    public static void QL_Hot(List <Contact> Le){
        map <String,List<Contact>> Records = new map <String,List<Contact>>();
        List<Contact> americaContacts = new List<Contact>();
        List<Contact> emeaContacts = new List<Contact>();
        List<Contact> apacContacts = new List<Contact>();
        
        for(Contact a : Le){
            switch on a.Global_Region__c{
                when 'Americas','None','Other'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **Americas or None**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'A_';
                    americaContacts.add(a);
                }
                when 'EMEA'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **EMEA**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'E_';
                    emeaContacts.add(a);
                }
                when 'APAC'{
                    system.debug('[Class] <PDG_Routing> Lead Region is **APAC**');
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'AP_';
                    apacContacts.add(a);
                }
            }
        }  
        Records.put('Americas',americaContacts);
        Records.put('EMEA',emeaContacts);
        Records.put('APAC',apacContacts);
        if(Records.size() > 0) PDG_Assign_Contact.HotRecords(Records);       
    }
    
}