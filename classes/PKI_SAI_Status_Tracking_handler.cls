public class PKI_SAI_Status_Tracking_handler {
    
    public static id CurrentUser = UserInfo.getUserId();
    
    // Check if records have new value in any of the SAI fields
    public static void CheckStatus(Map <id,Lead> records, map <id,Lead> Oldr){
        map <String, String> Sta = new map <String, String>();
        map <String, String> lq = new map <String, String>();
		
        
        schema.DescribeFieldResult stt = SAI_Status_Tracking__c.Status_Tracking_Fields__c.getdescribe();
        List<Schema.PicklistEntry> pl = stt.getpicklistvalues();
        
        schema.DescribeFieldResult lqs = Lead.PKI_LQS_Status_Fields__c.getdescribe();
        List<Schema.PicklistEntry> lqs_field = lqs.getpicklistvalues();  
        
        // For SAI Fields
        for(Schema.PicklistEntry pickListVal : pl){
            Sta.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        // For LQS fields
        for(Schema.PicklistEntry pickListVal : lqs_field){
            lq.put(pickListVal.getValue(), pickListVal.getLabel());
        } 
        
        system.debug(Sta);
        
        String [] StatusFields = new List<String>{};
            
            Set <Id>  SAILeads  = (Set<Id>)records.keyset();
        
        Map<string,Lead> ChangedStatus = new Map<string,Lead>();
        
        for(id a : SAILeads){
            Lead oldData = Oldr.get(a);
            Lead newData = records.get(a);
         
            for(string field : lq.KeySet()){
                Object v1 = oldData.get(field);
                Object v2 = newData.get(field);
                
                Boolean FieldIsChanged = (v1 != v2) ? true : false;
                
                if(FieldIsChanged && (v2 == 'Qualified Lead - Warm' || v2 == 'Qualified Lead - Hot')){
                 String [] ac = field.split('LQS'); 
                 String ST = 'Status' + ac[1];
                    system.debug('[PKI STATUS Tracking LQS Field:::]' + ac[1]);
                    Switch on ST{
                        when 'Status_Air__c'{
    						string va = records.get(a).Status_Air__c;
                            if(va != 'Working'){
                         records.get(a).Status_Air__c = 'Open';  
                            }
                        }
                        when 'Status_Applied_Genomics__c'{
    						string va = records.get(a).Status_Applied_Genomics__c;
                            if(va != 'Working'){
                         records.get(a).Status_Applied_Genomics__c = 'Open';  
                            }
                        }

                        when 'Status_Chemicals__c'{
    						string va = records.get(a).Status_Chemicals__c;
                            if(va != 'Working'){
                         records.get(a).Status_Chemicals__c = 'Open';  
                            }
                        }
                        when 'Status_Clinical_Studies__c'{
    						string va = records.get(a).Status_Clinical_Studies__c;
                            if(va != 'Working'){
                         records.get(a).Status_Clinical_Studies__c = 'Open';  
                            }
                        }
                        when 'Status_Digital_Lab__c'{
    						string va = records.get(a).Status_Digital_Lab__c;
                            if(va != 'Working'){
                         records.get(a).Status_Digital_Lab__c = 'Open';  
                            }
                        }
                        when 'Status_Disease_Research__c'{
    						string va = records.get(a).Status_Disease_Research__c;
                            if(va != 'Working'){
                         records.get(a).Status_Disease_Research__c = 'Open';  
                            }
                        }
                        when 'Status_Drug_Discovery__c'{
    						string va = records.get(a).Status_Drug_Discovery__c;
                            if(va != 'Working'){
                         records.get(a).Status_Drug_Discovery__c = 'Open';  
                            }
                        }
                        when 'Status_Energy__c'{
    						string va = records.get(a).Status_Energy__c;
                            if(va != 'Working'){
                         records.get(a).Status_Energy__c = 'Open';  
                            }
                        }
                        when 'Status_Food_Quality__c'{
    						string va = records.get(a).Status_Food_Quality__c;
                            if(va != 'Working'){
                         records.get(a).Status_Food_Quality__c = 'Open';  
                            }
                        }
                        when 'Status_Food_Safety__c'{
    						string va = records.get(a).Status_Food_Safety__c;
                            if(va != 'Working'){
                         records.get(a).Status_Food_Safety__c = 'Open';  
                            }
                        }
                        when 'Status_Forensics_and_Security__c'{
    						string va = records.get(a).Status_Forensics_and_Security__c;
                            if(va != 'Working'){
                         records.get(a).Status_Forensics_and_Security__c = 'Open';  
                            }
                        }
                        when 'Status_Geochemistry_Mining_and_Metals__c'{
    						string va = records.get(a).	Status_Geochemistry_Mining_and_Metals__c;
                            if(va != 'Working'){
                         records.get(a).Status_Geochemistry_Mining_and_Metals__c = 'Open';  
                            }
                        }
                        when 'Status_Material__c'{
    						string va = records.get(a).Status_Material__c;
                            if(va != 'Working'){
                         records.get(a).Status_Material__c = 'Open';  
                            }
                        }
                        
                        when 'Status_Maternal_Fetal_Health__c'{
    						string va = records.get(a).Status_Maternal_Fetal_Health__c;
                            if(va != 'Working'){
                         records.get(a).Status_Maternal_Fetal_Health__c = 'Open';  
                            }
                        }
                        when 'Status_Newborn_Screening__c'{
    						string va = records.get(a).Status_Newborn_Screening__c;
                            if(va != 'Working'){
                         records.get(a).Status_Newborn_Screening__c = 'Open';  
                            }
                        }
                        when 'Status_Pre_Clinical_Studies__c'{
    						string va = records.get(a).Status_Pre_Clinical_Studies__c;
                            if(va != 'Working'){
                         records.get(a).Status_Pre_Clinical_Studies__c = 'Open';  
                            }
                        }
                        when 'Status_QA_QC_Drug_Manufacturing_Process__c'{
    						string va = records.get(a).Status_QA_QC_Drug_Manufacturing_Process__c;
                            if(va != 'Working'){
                         records.get(a).Status_QA_QC_Drug_Manufacturing_Process__c = 'Open';  
                            }
                        }
                        when 'Status_Soil_Solids__c'{
    						string va = records.get(a).Status_Soil_Solids__c;
                            if(va != 'Working'){
                         records.get(a).Status_Soil_Solids__c = 'Open';  
                            }
                        }
                        when 'Status_Strategic_Services__c'{
    						string va = records.get(a).Status_Strategic_Services__c;
                            if(va != 'Working'){
                         records.get(a).Status_Strategic_Services__c = 'Open';  
                            }
                        }
                        when 'Status_Water__c'{
    						string va = records.get(a).Status_Water__c;
                            if(va != 'Working'){
                         records.get(a).Status_Water__c = 'Open';  
                            }
                        }
                    }
               
                }  
            }    
            
            for(string field : Sta.KeySet()){
                Object v1 = oldData.get(field);
                Object v2 = newData.get(field);               
                if(StatusChange(v1, v2)){
                    system.debug('###1' + v1 + ' ||||| ' + v2);
                    ChangedStatus.put(a + ',' + v1 + ',' + v2 + ',' + field + ',' + Sta.get(field), (Lead)newData);
                } 
            }
            
        }
        system.debug('ChangedStatus size: ' + ChangedStatus.size());
        if(ChangedStatus.size()>0){CreateStatusTrackingRecord(ChangedStatus);}
    }
    
    // Create new SAI tracking record
    public static void CreateStatusTrackingRecord(map<string,Lead> RecordsThatChanged){
        Set <String> Id_Value_Field =  RecordsThatChanged.keySet();
        List <SAI_Status_Tracking__c> SST = new List <SAI_Status_Tracking__c>();
        
        for(String a : Id_Value_Field){
            String[] values = a.split(',');
            
            SAI_Status_Tracking__c st = new SAI_Status_Tracking__c();
            st.Modified_Date_Time__c = System.now();
            st.Lead__c = RecordsThatChanged.get(a).id;
            st.Email_Address__c = RecordsThatChanged.get(a).Email;
            st.Modified_By__c = CurrentUser;
            st.Field_Name__c = values[4];
            st.Previous_Value__c = values[1]; 
            st.New_Value__c = values[2];
            st.Dispensation_SLA__c = RecordsThatChanged.get(a).Dispensation_SLA__c;
            st.Conversion_SLA__c = RecordsThatChanged.get(a).Conversion_SLA__c;
            
            SST.add(st); 
        }
        insert SST;
    }
    
    // Check if records have new value in any of the SAI fields
    public static void CheckStatus_C(Map <id,Contact> records, map <id,Contact> Oldr){
       map <String, String> Sta = new map <String, String>();
        map <String, String> lq = new map <String, String>();
		
        
        schema.DescribeFieldResult stt = SAI_Status_Tracking__c.Status_Tracking_Fields__c.getdescribe();
        List<Schema.PicklistEntry> pl = stt.getpicklistvalues();
        
        schema.DescribeFieldResult lqs = Lead.PKI_LQS_Status_Fields__c.getdescribe();
        List<Schema.PicklistEntry> lqs_field = lqs.getpicklistvalues();  
        
        // For SAI Fields
        for(Schema.PicklistEntry pickListVal : pl){
            Sta.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        // For LQS fields
        for(Schema.PicklistEntry pickListVal : lqs_field){
            lq.put(pickListVal.getValue(), pickListVal.getLabel());
        } 
     
        system.debug(Sta);
        String [] StatusFields = new List<String>{};
            
            Set <Id>  SAILeads  = (Set<Id>) records.keyset();
        Map<string,Contact> ChangedStatus = new Map<string,Contact>();
        
        for(id a : SAILeads){
            sObject oldData = Oldr.get(a);
            sObject newData = records.get(a);

            for(string field : lq.KeySet()){
                Object v1 = oldData.get(field);
                Object v2 = newData.get(field);
                
                Boolean FieldIsChanged = (v1 != v2) ? true : false;

                if(FieldIsChanged && (v2 == 'Qualified Lead - Warm' || v2 == 'Qualified Lead - Hot')){
                 String [] ac = field.split('LQS'); 
                 String ST = 'Status' + ac[1];
                    system.debug('[PKI STATUS Tracking LQS Field:::]' + ac[1]);
                    Switch on ST{
                        when 'Status_Air__c'{
    						string va = records.get(a).Status_Air__c;
                            if(va != 'Working'){
                         records.get(a).Status_Air__c = 'Open';  
                            }
                        }
                        when 'Status_Applied_Genomics__c'{
    						string va = records.get(a).Status_Applied_Genomics__c;
                            if(va != 'Working'){
                         records.get(a).Status_Applied_Genomics__c = 'Open';  
                            }
                        }
                        when 'Status_Chemicals__c'{
    						string va = records.get(a).Status_Chemicals__c;
                            if(va != 'Working'){
                         records.get(a).Status_Chemicals__c = 'Open';  
                            }
                        }
                        when 'Status_Clinical_Studies__c'{
    						string va = records.get(a).Status_Clinical_Studies__c;
                            if(va != 'Working'){
                         records.get(a).Status_Clinical_Studies__c = 'Open';  
                            }
                        }
                        when 'Status_Digital_Lab__c'{
    						string va = records.get(a).Status_Digital_Lab__c;
                            if(va != 'Working'){
                         records.get(a).Status_Digital_Lab__c = 'Open';  
                            }
                        }
                        when 'Status_Disease_Research__c'{
    						string va = records.get(a).Status_Disease_Research__c;
                            if(va != 'Working'){
                         records.get(a).Status_Disease_Research__c = 'Open';  
                            }
                        }
                        when 'Status_Drug_Discovery__c'{
    						string va = records.get(a).Status_Drug_Discovery__c;
                            if(va != 'Working'){
                         records.get(a).Status_Drug_Discovery__c = 'Open';  
                            }
                        }
                        when 'Status_Energy__c'{
    						string va = records.get(a).Status_Energy__c;
                            if(va != 'Working'){
                         records.get(a).Status_Energy__c = 'Open';  
                            }
                        }
                        when 'Status_Food_Quality__c'{
    						string va = records.get(a).Status_Food_Quality__c;
                            if(va != 'Working'){
                         records.get(a).Status_Food_Quality__c = 'Open';  
                            }
                        }
                        when 'Status_Food_Safety__c'{
    						string va = records.get(a).Status_Food_Safety__c;
                            if(va != 'Working'){
                         records.get(a).Status_Food_Safety__c = 'Open';  
                            }
                        }
                        when 'Status_Forensics_and_Security__c'{
    						string va = records.get(a).Status_Forensics_and_Security__c;
                            if(va != 'Working'){
                         records.get(a).Status_Forensics_and_Security__c = 'Open';  
                            }
                        }
                        when 'Status_Geochemistry_Mining_and_Metals__c'{
    						string va = records.get(a).	Status_Geochemistry_Mining_and_Metals__c;
                            if(va != 'Working'){
                         records.get(a).Status_Geochemistry_Mining_and_Metals__c = 'Open';  
                            }
                        }
                        when 'Status_Material__c'{
    						string va = records.get(a).Status_Material__c;
                            if(va != 'Working'){
                         records.get(a).Status_Material__c = 'Open';  
                            }
                        }
                        
                        when 'Status_Maternal_Fetal_Health__c'{
    						string va = records.get(a).Status_Maternal_Fetal_Health__c;
                            if(va != 'Working'){
                         records.get(a).Status_Maternal_Fetal_Health__c = 'Open';  
                            }
                        }
                        when 'Status_Newborn_Screening__c'{
    						string va = records.get(a).Status_Newborn_Screening__c;
                            if(va != 'Working'){
                         records.get(a).Status_Newborn_Screening__c = 'Open';  
                            }
                        }
                        when 'Status_Pre_Clinical_Studies__c'{
    						string va = records.get(a).Status_Pre_Clinical_Studies__c;
                            if(va != 'Working'){
                         records.get(a).Status_Pre_Clinical_Studies__c = 'Open';  
                            }
                        }
                        when 'Status_QA_QC_Drug_Manufacturing_Process__c'{
    						string va = records.get(a).Status_QA_QC_Drug_Manufacturing_Process__c;
                            if(va != 'Working'){
                         records.get(a).Status_QA_QC_Drug_Manufacturing_Process__c = 'Open';  
                            }
                        }
                        when 'Status_Soil_Solids__c'{
    						string va = records.get(a).Status_Soil_Solids__c;
                            if(va != 'Working'){
                         records.get(a).Status_Soil_Solids__c = 'Open';  
                            }
                        }
                        when 'Status_Strategic_Services__c'{
    						string va = records.get(a).Status_Strategic_Services__c;
                            if(va != 'Working'){
                         records.get(a).Status_Strategic_Services__c = 'Open';  
                            }
                        }
                        when 'Status_Water__c'{
    						string va = records.get(a).Status_Water__c;
                            if(va != 'Working'){
                         records.get(a).Status_Water__c = 'Open';  
                            }
                        }
                    }
               
                }  
            }    
                        
            for(string field : Sta.KeySet()){
                Object v1 = oldData.get(field);
                Object v2 = newData.get(field);               
                
                if(StatusChange(v1, v2)){
                    system.debug('###1' + v1 + ' ||||| ' + v2);
                    ChangedStatus.put(a + ',' + v1 + ',' + v2 + ',' + field + ',' + Sta.get(field), (Contact)newData);
                }           
                
            }
            
        }
        if(ChangedStatus.size()>0){
            CreateStatusTrackingRecord_C(ChangedStatus);
        }
        
    }
    
    // Create new SAI tracking record
    public static void CreateStatusTrackingRecord_C(map<string,Contact> RecordsThatChanged){
        Set <String> Id_Value_Field =  RecordsThatChanged.keySet();
        map <id, id> Opp2 = new map <id, id>();
        List <SAI_Status_Tracking__c> SST = new List <SAI_Status_Tracking__c>();
        List <Contact> ContactsToCheckForOpp = RecordsThatChanged.values();
        map <id, contact> OCR = new map<id,contact>();
        
        for(Contact b : ContactsToCheckForOpp){
            OCR.put(b.id, b);
        }
        
        if(OCR.size()>0){
            for(OpportunityContactRole a : [Select OpportunityId, ContactId from OpportunityContactRole 
                                            where ContactId IN:OCR.keySet() order by CreatedDate DESC limit 1]){
                                                Opp2.put(a.ContactId, a.OpportunityId);  
                                            }
        }
        
        
        for(String a : Id_Value_Field){
            String[] values = a.split(',');
            
            SAI_Status_Tracking__c st = new SAI_Status_Tracking__c();
            st.Modified_Date_Time__c = System.now();
            st.Contact__c = RecordsThatChanged.get(a).id;
            st.Email_Address__c = RecordsThatChanged.get(a).Email;
            st.Modified_By__c = CurrentUser;
            st.Field_Name__c = values[4];
            st.Previous_Value__c = values[1]; 
            st.New_Value__c = values[2];
            st.Dispensation_SLA__c = RecordsThatChanged.get(a).Dispensation_SLA__c;
            st.Conversion_SLA__c = RecordsThatChanged.get(a).Conversion_SLA__c;
            if(!String.isBlank(Opp2.get(values[0]))){
                st.Corresponding_Opportunity__c = Opp2.get(values[0]);
            }
            
            SST.add(st); 
        }
        insert SST;
    }
    
    private static Boolean StatusChange(Object a, Object b) {
        if (a == null && b == null) {
            return false;
        }
        if (a != b) {
            return true;
        }
        return false;
    }
    
    // Update Contact created or updated from Lead with the Related SAI tracking record
    public static void UpdateContactRelatedList(map<string,Contact> ContactRelatedList){
        system.debug('[][][]WE ARE HERE!!!!');
        List <Contact> CT = new List<Contact>();
        List <Contact> UP = ContactRelatedList.values();
        list <SAI_Status_Tracking__c> ud = [select Field_Name__c, Email_Address__c, Lead__c, Contact__c from SAI_Status_Tracking__c where Lead__c in:ContactRelatedList.keySet()];
        PDG_Routing_Class.is_Firstb = true;
        if(ud.size() >0){
            for(SAI_Status_Tracking__c a : ud){
                a.Contact__c = ContactRelatedList.get(a.Lead__c).id;
            } 
            update ud;
        }
        if(trigger.isBefore){
        if(UP.size()>0){
            for(Contact a : UP){
                a.ConvertedRecordId__c = null;  
            }
        }  
        }
    }
    
}