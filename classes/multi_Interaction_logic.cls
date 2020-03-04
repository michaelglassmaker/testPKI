public class multi_Interaction_logic {
    /*
Purpose for this class:
This class is designed to be a handler class for
PDG program. Leads and contacts will be passed to 
this class to cycle through various conditions and 
appened the JSON table to the description field

Developed by ANNUITAS
*/    
    public static boolean is_First = true;
    public static string EmailAddress = 'None';
    public static string ContentOfferSerial = 'None';
    public static string PageVisitTime = 'None';
    public static string InteractionDatetime;
    public static string Channel = 'None';
    public static string Source = 'None';
    public static string Keyword = 'None';
    public static string Device = 'None';
    public static string PreviousPage = 'None';
    public static string Tactic = 'None';
    public static string Action = 'None';
    public static string Form = 'None';    
    public static string FormCount = 'None';
    public static string SFDC_Campaign_ID = 'None';
    public static string PpcAd = 'None';
    public static string PpcAdGroup = 'None';
    public static String randStr;
    
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    public static string val;
    public static Boolean UpdateRecord;
    List<Lead> newList;
    map<id,Lead> oldList;
    List<Contact> newList_Contact;
    map<id,Contact> oldList_Contact;
    map<string,Contact> ListForStatusTracking = new map <string,Contact>();
    List<Lead> updateList_L = new List<Lead>();
    List<Contact> updateList_C = new List<Contact>();
    
    
    public multi_Interaction_logic(List<Lead> New_Leads, map<id,Lead> Old_Leads){
        newList = New_Leads; 
        oldList = Old_Leads; 
    }
    
    public multi_Interaction_logic(List<Contact> New_Contacts, map<id,Contact> Old_Contacts){
        newList_Contact = New_Contacts; 
        oldList_Contact = Old_Contacts; 
    }
    
    
    public void Lead_Records() {
        // Prevent recursive loops //
        // if(is_First){
        if(Trigger.isBefore && Trigger.isInsert){
            // is_First = false;
            system.debug('[Class] <multi_Interaction_logic> : IsBefore');
            
            for(Lead a : newList){
                //if(is_First || (!is_First && !a.Is_Multi_Interaction_Logic__c)){
                    //a.Is_Multi_Interaction_Logic__c = true;
                    if(a.Eloqua_List_Upload_Date__c != null){
                        randStr = 'ANN';
                        
                        while (randStr.length() < 18) {
                            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                            randStr += chars.substring(idx, idx+1);
                        }
                        
                        system.debug('RandomString = ' + randStr);
                        
                        InteractionDatetime = (a.Eloqua_Event_Date__c != null) ? string.valueOfGmt(a.Eloqua_Event_Date__c)
                            : (string.isBlank(a.Eloqua_Event_Status__c)) ? string.valueOfGmt(system.now())
                                :(a.Eloqua_Event_Status__c == 'None') ? string.valueOfGmt(system.now())
                                    : (a.Eloqua_Event_Status__c.contains('Regist')) ? string.valueOfGmt(system.now())
                                        : (!a.Eloqua_Event_Status__c.contains('Regist')) ? string.valueOfGmt(a.Eloqua_Event_Date__c)
                                            :  string.valueOfGmt(system.now());
                        
                        
                        
                        
                        
                        InteractionDatetime = (string.isEmpty(InteractionDatetime)) ? string.valueOfGmt(system.now()) : InteractionDatetime;                  
                        //InteractionDatetime = (a.Eloqua_Event_Date__c != null) ? string.valueOfGmt(a.Eloqua_Event_Date__c) : '0000-00-00 00:00:00';                    
                        String[] fdate = InteractionDatetime.split(' ');
                        String ddate = fdate[0];
                        String adate = fdate[1];
                        String[] edate = ddate.split('-');
                        InteractionDatetime = edate[1] + '/';
                        InteractionDatetime += edate[2] + '/';
                        InteractionDatetime += edate[0];
                        
                        // Format Time
                        String[] bdate = adate.split(':'); // convert to array
                        
                        // fetch
                        integer hours = integer.valueof(bdate[0]);
                        integer minutes = integer.valueof(bdate[1]);
                        integer seconds = integer.valueof(bdate[2]);
                        
                        // calculate
                        String timeValue;
                        
                        if (hours > 0 && hours <= 12) {
                            timeValue= '' + hours;
                        } else if (hours > 12) {
                            timeValue= '' + (hours - 12);
                        } else if (hours == 0) {
                            timeValue= '12';
                        }
                        
                        timeValue += (minutes < 10) ? ':0' + minutes : ':' + minutes;  // get minutes
                        timeValue += (seconds < 10) ? ':0' + seconds : ':' + seconds;  // get seconds
                        timeValue += (hours >= 12) ? ' P.M.' : ' A.M.';  // get AM/PM
                        
                        boolean Des_is_empty = (string.isEmpty(a.Description));
                        InteractionDatetime = InteractionDatetime + ' ' + timeValue;  
                        EmailAddress = a.Email;
                        Channel = (string.isEmpty(a.Last_Lead_Source_Channel__c)) ? 'None' : a.Last_Lead_Source_Channel__c;
                        Source = (string.isEmpty(a.Last_Lead_Source_Partner__c)) ? 'None' : a.Last_Lead_Source_Partner__c;
                        Tactic = (string.isEmpty(a.Last_Lead_Source_Content__c)) ? 'None' : a.Last_Lead_Source_Content__c;
                        Action = (string.isEmpty(a.Eloqua_Event_Status__c)) ? 'None' : a.Eloqua_Event_Status__c;
                        ContentOfferSerial = (string.isEmpty(a.Last_CO__c)) ? 'None' : a.Last_CO__c;
                        SFDC_Campaign_ID = (string.isEmpty(a.Last_SFDC_Campaign_ID__c)) ? 'None' : a.Last_SFDC_Campaign_ID__c;
                        
                        if(Des_is_empty){
                            // If description field is blank, insert string below //
                            val = '[{"Email Address" : "'+EmailAddress+'","Unique ID" : "'+randStr+'","Content Offer Serial" : "'+ContentOfferSerial+'","Page Visit Datetime" : "'+PageVisitTime+'","Interaction Datetime" : "'+InteractionDatetime+'","Channel" : "'+Channel+'","Source" : "'+Source+'","Keyword" : "'+Keyword+'","Device" : "'+Device+'","Previous Page" : "'+PreviousPage+'","Tactic" : "'+Tactic+'","Action" : "'+Action+'","Form" : "'+Form+'","Form Count" : "'+FormCount+'","SFDC Campaign ID" : "'+SFDC_Campaign_ID+'","PPC Ad" : "'+PpcAd+'","PPC Ad Group" : "'+PpcAdGroup+'"}]';
                            a.Description = val;
                            system.debug('[Class] <multi_Interaction_logic> : Description field is empty');
                            system.debug('[Class] <multi_Interaction_logic> :' + a.Description);
                        }
                        
                    }
                //}
            }
           // is_First = false;
        }
        
        else if(Trigger.isBefore && Trigger.isUpdate){
            // is_First = false;
            system.debug('[Class] <multi_Interaction_logic> : Trigger isBefore && Trigger isUpdate');
            map <id,Lead> Lead_Ids = new map <id,Lead>();
            List <Lead> new_Leads = new List<Lead>();                
            for(Lead a : newList){
               // if(is_First || (!is_First && !a.Is_Multi_Interaction_Logic__c)){
                    //a.Is_Multi_Interaction_Logic__c = true;
                    UpdateRecord = (a.Eloqua_List_Upload_Date__c != oldList.get(a.id).Eloqua_List_Upload_Date__c);
                    system.debug('[Class] <multi_Interaction_logic> : Dates -' + a.Eloqua_List_Upload_Date__c + ' : ' + oldList.get(a.id).Eloqua_List_Upload_Date__c);
                    system.debug('[Class] <multi_Interaction_logic> : Dates are different = ' + UpdateRecord);
                    
                    if(UpdateRecord){
                        Lead_Ids.put(a.id, a);
                        system.debug('[Class] <multi_Interaction_logic> : id added to Lead_Ids = ' + a.id +':'+ a.email);
                        
                    }
               // }
            }
          //  is_First = false;
            if(Lead_Ids.size() > 0){
                //new_Leads = [Select id,Email,Eloqua_Event_Date__c,Eloqua_List_Upload_Date__c,Eloqua_Event_Status__c,Description from Lead where id IN:Lead_Ids.keyset()];
                
                for(Lead c : Lead_Ids.values()){
                    system.debug('**** Date Format ****' + string.valueOfGmt(Lead_Ids.get(c.id).Eloqua_List_Upload_Date__c));
                    InteractionDatetime = (c.Eloqua_Event_Date__c != null) ? string.valueOfGmt(c.Eloqua_Event_Date__c)
                        : (string.isBlank(c.Eloqua_Event_Status__c)) ? string.valueOfGmt(system.now())
                            :(c.Eloqua_Event_Status__c == 'None') ? string.valueOfGmt(system.now())
                                : (c.Eloqua_Event_Status__c.contains('Regist')) ? string.valueOfGmt(system.now())
                                    : (!c.Eloqua_Event_Status__c.contains('Regist')) ? string.valueOfGmt(c.Eloqua_Event_Date__c)
                                        :  string.valueOfGmt(system.now());
                    
                    
                    InteractionDatetime = (string.isEmpty(InteractionDatetime)) ? string.valueOfGmt(system.now()) : InteractionDatetime;                  
                    //InteractionDatetime = string.valueOfGmt(Lead_Ids.get(c.id).Eloqua_Event_Date__c);                    
                    String[] fdate = InteractionDatetime.split(' ');
                    String ddate = fdate[0];
                    String adate = fdate[1];
                    String[] edate = ddate.split('-');
                    InteractionDatetime = edate[1] + '/';
                    InteractionDatetime += edate[2] + '/';
                    InteractionDatetime += edate[0];
                    
                    // Format Time
                    String[] bdate = adate.split(':'); // convert to array
                    
                    // fetch
                    integer hours = integer.valueof(bdate[0]);
                    integer minutes = integer.valueof(bdate[1]);
                    integer seconds = integer.valueof(bdate[2]);
                    
                    // calculate
                    String timeValue;
                    
                    if (hours > 0 && hours <= 12) {
                        timeValue= '' + hours;
                    } else if (hours > 12) {
                        timeValue= '' + (hours - 12);
                    } else if (hours == 0) {
                        timeValue= '12';
                    }
                    
                    timeValue += (minutes < 10) ? ':0' + minutes : ':' + minutes;  // get minutes
                    timeValue += (seconds < 10) ? ':0' + seconds : ':' + seconds;  // get seconds
                    timeValue += (hours >= 12) ? ' P.M.' : ' A.M.';  // get AM/PM
                    
                    system.debug(InteractionDatetime + ' ' + timeValue);
                    
                    
                    boolean Des_is_not_empty = (!string.isEmpty(c.Description));
                    boolean ListUploadDateNotEmpty = (c.Eloqua_List_Upload_Date__c != null);
                    EmailAddress = Lead_Ids.get(c.id).Email;
                    InteractionDatetime = InteractionDatetime + ' ' + timeValue;                    
                    Channel = (string.isEmpty(Lead_Ids.get(c.id).Last_Lead_Source_Channel__c)) ? 'None' : Lead_Ids.get(c.id).Last_Lead_Source_Channel__c;
                    Source = (string.isEmpty(Lead_Ids.get(c.id).Last_Lead_Source_Partner__c)) ? 'None' : Lead_Ids.get(c.id).Last_Lead_Source_Partner__c;
                    Tactic = (string.isEmpty(Lead_Ids.get(c.id).Last_Lead_Source_Content__c)) ? 'None' : Lead_Ids.get(c.id).Last_Lead_Source_Content__c;
                    Action = (string.isEmpty(Lead_Ids.get(c.id).Eloqua_Event_Status__c)) ? 'None' : Lead_Ids.get(c.id).Eloqua_Event_Status__c;
                    ContentOfferSerial = (string.isEmpty(c.Last_CO__c)) ? 'None' : c.Last_CO__c;
                    SFDC_Campaign_ID = (string.isEmpty(c.Last_SFDC_Campaign_ID__c)) ? 'None' : c.Last_SFDC_Campaign_ID__c;
                    val = c.Description;
                    system.debug('[Class] <multi_Interaction_logic> : Original - ' + c.Description);
                    system.debug('[Class] <multi_Interaction_logic> : Dates are different 2 = ' + UpdateRecord);
                    system.debug('[Class] <multi_Interaction_logic> : Dates are = ' + c.Eloqua_List_Upload_Date__c + ' : ' + oldList.get(c.id).Eloqua_List_Upload_Date__c);
                    if(ListUploadDateNotEmpty){
                        if(Des_is_not_empty){ 
                            randStr = 'ANN';
                            while (randStr.length() < 18) {
                                Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                                randStr += chars.substring(idx, idx+1);
                            }
                            //String store = val.replace('[','');
                            //store = store.replace(']','');
                            //Map<String, Object> uid =(Map<String, Object>)JSON.deserializeUntyped(store);
                            
                            //system.debug('String Array: ' + store);
                            //system.debug('String Array2: ' + uid.get('Unique ID'));
                            
                            // If description field is not blank, insert string below //
                            String val2 = ',{"Email Address" : "'+EmailAddress+'","Unique ID" : "'+randStr+'","Content Offer Serial" : "'+ContentOfferSerial+'","Page Visit Datetime" : "'+PageVisitTime+'","Interaction Datetime" : "'+InteractionDatetime+'","Channel" : "'+Channel+'","Source" : "'+Source+'","Keyword" : "'+Keyword+'","Device" : "'+Device+'","Previous Page" : "'+PreviousPage+'","Tactic" : "'+Tactic+'","Action" : "'+Action+'","Form" : "'+Form+'","Form Count" : "'+FormCount+'","SFDC Campaign ID" : "'+SFDC_Campaign_ID+'","PPC Ad" : "'+PpcAd+'","PPC Ad Group" : "'+PpcAdGroup+'"}]'; 
                            c.Description = val.substring(0, val.length() - 1) + val2;
                            system.debug('[Class] <multi_Interaction_logic> : Description field is not empty');
                            system.debug('[Class] <multi_Interaction_logic> New:' + c.Description);
                            updateList_L.add(c);
                            
                        }
                        
                        else if (!Des_is_not_empty && UpdateRecord){
                            randStr = 'ANN';
                            while (randStr.length() < 18) {
                                Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                                randStr += chars.substring(idx, idx+1);
                            }
                            // If description field is not blank, insert string below //
                            String val2 = '[{"Email Address" : "'+EmailAddress+'","Unique ID" : "'+randStr+'","Content Offer Serial" : "'+ContentOfferSerial+'","Page Visit Datetime" : "'+PageVisitTime+'","Interaction Datetime" : "'+InteractionDatetime+'","Channel" : "'+Channel+'","Source" : "'+Source+'","Keyword" : "'+Keyword+'","Device" : "'+Device+'","Previous Page" : "'+PreviousPage+'","Tactic" : "'+Tactic+'","Action" : "'+Action+'","Form" : "'+Form+'","Form Count" : "'+FormCount+'","SFDC Campaign ID" : "'+SFDC_Campaign_ID+'","PPC Ad" : "'+PpcAd+'","PPC Ad Group" : "'+PpcAdGroup+'"}]'; 
                            c.Description = val2;
                            system.debug('[Class] <multi_Interaction_logic> : Description field is not empty');
                            system.debug('[Class] <multi_Interaction_logic> New:' + c.Description);
                            updateList_L.add(c);  
                        }
                    }
                }
                
            }
            if(updateList_L.size() > 0){
                // update updateList_L;
            }
        }
        //  }
    }
    
    
    public void Contact_Records(){
        // Prevent recursive loops //
        //if(is_First){
            /*if(Trigger.isBefore && Trigger.isInsert){
is_First = false;
system.debug('[Class] <multi_Interaction_logic> : IsBefore');

for(Contact a : newList_Contact){
if(a.Eloqua_List_Upload_Date__c != null){
randStr = 'ANN';
while (randStr.length() < 18) {
Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
randStr += chars.substring(idx, idx+1);
}

system.debug('RandomString = ' + randStr);

InteractionDatetime = (a.Eloqua_Event_Date__c != null) ? string.valueOfGmt(a.Eloqua_Event_Date__c)
: (string.isBlank(a.Eloqua_Event_Status__c)) ? string.valueOfGmt(system.now())
:(a.Eloqua_Event_Status__c == 'None') ? string.valueOfGmt(system.now())
: (a.Eloqua_Event_Status__c.contains('Regist')) ? string.valueOfGmt(system.now())
: (!a.Eloqua_Event_Status__c.contains('Regist')) ? string.valueOfGmt(a.Eloqua_Event_Date__c)
:  string.valueOfGmt(system.now());





InteractionDatetime = (string.isEmpty(InteractionDatetime)) ? string.valueOfGmt(system.now()) : InteractionDatetime;                  
String[] fdate = InteractionDatetime.split(' ');
String ddate = fdate[0];
String adate = fdate[1];
String[] edate = ddate.split('-');
InteractionDatetime = edate[1] + '/';
InteractionDatetime += edate[2] + '/';
InteractionDatetime += edate[0];

// Format Time
String[] bdate = adate.split(':'); // convert to array

// fetch
integer hours = integer.valueof(bdate[0]);
integer minutes = integer.valueof(bdate[1]);
integer seconds = integer.valueof(bdate[2]);

// calculate
String timeValue;

if (hours > 0 && hours <= 12) {
timeValue= '' + hours;
} else if (hours > 12) {
timeValue= '' + (hours - 12);
} else if (hours == 0) {
timeValue= '12';
}

timeValue += (minutes < 10) ? ':0' + minutes : ':' + minutes;  // get minutes
timeValue += (seconds < 10) ? ':0' + seconds : ':' + seconds;  // get seconds
timeValue += (hours >= 12) ? ' P.M.' : ' A.M.';  // get AM/PM

boolean Des_is_empty = (string.isEmpty(a.Description));
InteractionDatetime = InteractionDatetime + ' ' + timeValue;  
EmailAddress = a.Email;
Channel = (string.isEmpty(a.Last_Lead_Source_Channel__c)) ? 'None' : a.Last_Lead_Source_Channel__c;
Source = (string.isEmpty(a.Last_Lead_Source_Partner__c)) ? 'None' : a.Last_Lead_Source_Partner__c;
Tactic = (string.isEmpty(a.Last_Lead_Source_Content__c)) ? 'None' : a.Last_Lead_Source_Content__c;
Action = (string.isEmpty(a.Eloqua_Event_Status__c)) ? 'None' : a.Eloqua_Event_Status__c;
ContentOfferSerial = (string.isEmpty(a.Last_CO__c)) ? 'None' : a.Last_CO__c;
SFDC_Campaign_ID = (string.isEmpty(a.Last_SFDC_Campaign_ID__c)) ? 'None' : a.Last_SFDC_Campaign_ID__c;

if(Des_is_empty && a.Eloqua_List_Upload_Date__c != null){
// If description field is blank, insert string below //
val = '[{"Email Address" : "'+EmailAddress+'","Unique ID" : "'+randStr+'","Content Offer Serial" : "'+ContentOfferSerial+'","Page Visit Datetime" : "'+PageVisitTime+'","Interaction Datetime" : "'+InteractionDatetime+'","Channel" : "'+Channel+'","Source" : "'+Source+'","Keyword" : "'+Keyword+'","Device" : "'+Device+'","Previous Page" : "'+PreviousPage+'","Tactic" : "'+Tactic+'","Action" : "'+Action+'","Form" : "'+Form+'","Form Count" : "'+FormCount+'","SFDC Campaign ID" : "'+SFDC_Campaign_ID+'","PPC Ad" : "'+PpcAd+'","PPC Ad Group" : "'+PpcAdGroup+'"}]';
a.Description = val;
system.debug('[Class] <multi_Interaction_logic> : Description field is empty');
system.debug('[Class] <multi_Interaction_logic> :' + a.Description);
}

}
}

}*/
            
            if(Trigger.isBefore && Trigger.isUpdate){
                //is_First = false;
                system.debug('[Class] <multi_Interaction_logic> : Trigger isBefore && Trigger isUpdate');
                map <id,Contact> Contact_Ids = new map <id,Contact>();
                List <Contact> new_Contact = new List<Contact>();                
                for(Contact a :  newList_Contact){
                    UpdateRecord = (a.Eloqua_List_Upload_Date__c != oldList_Contact.get(a.id).Eloqua_List_Upload_Date__c);
                    system.debug('[Class] <multi_Interaction_logic> : Dates -' + a.Eloqua_List_Upload_Date__c + ' : ' + oldList_Contact.get(a.id).Eloqua_List_Upload_Date__c);
                    system.debug('[Class] <multi_Interaction_logic> : Dates are different = ' + UpdateRecord);
                    
                    if(UpdateRecord && a.Converted_QL__c == 'true'){
                        a.Converted_QL__c = '';                   
                    }                       
                    else if(UpdateRecord && (a.Converted_QL__c != 'true' && a.Converted_QL__c != 'false')){
                        Contact_Ids.put(a.id, a);
                        system.debug('[Class] <multi_Interaction_logic> : id added to Contact_Ids = ' + a.id +':'+ a.email);
                        
                    }
                     
                }
                if(Contact_Ids.size() > 0){
                    //new_Contact = [Select id,Email,Eloqua_Event_Date__c,Eloqua_List_Upload_Date__c,Eloqua_Event_Status__c,Description from Contact where id IN:Contact_Ids.keyset()];
                    
                    for(Contact c : Contact_Ids.values()){
                        system.debug('**** Date Format ****' + string.valueOfGmt(c.Eloqua_List_Upload_Date__c));
                        InteractionDatetime = (c.Eloqua_Event_Date__c != null) ? string.valueOfGmt(c.Eloqua_Event_Date__c)
                            : (string.isBlank(c.Eloqua_Event_Status__c)) ? string.valueOfGmt(system.now())
                                :(c.Eloqua_Event_Status__c == 'None') ? string.valueOfGmt(system.now())
                                    : (c.Eloqua_Event_Status__c.contains('Regist')) ? string.valueOfGmt(system.now())
                                        : (!c.Eloqua_Event_Status__c.contains('Regist')) ? string.valueOfGmt(c.Eloqua_Event_Date__c)
                                            :  string.valueOfGmt(system.now());
                        
                        
                        InteractionDatetime = (string.isEmpty(InteractionDatetime)) ? string.valueOfGmt(system.now()) : InteractionDatetime;                  
                        String[] fdate = InteractionDatetime.split(' ');
                        String ddate = fdate[0];
                        String adate = fdate[1];
                        String[] edate = ddate.split('-');
                        InteractionDatetime = edate[1] + '/';
                        InteractionDatetime += edate[2] + '/';
                        InteractionDatetime += edate[0];
                        
                        // Format Time
                        String[] bdate = adate.split(':'); // convert to array
                        
                        // fetch
                        integer hours = integer.valueof(bdate[0]);
                        integer minutes = integer.valueof(bdate[1]);
                        integer seconds = integer.valueof(bdate[2]);
                        
                        // calculate
                        String timeValue;
                        
                        if (hours > 0 && hours <= 12) {
                            timeValue= '' + hours;
                        } else if (hours > 12) {
                            timeValue= '' + (hours - 12);
                        } else if (hours == 0) {
                            timeValue= '12';
                        }
                        
                        timeValue += (minutes < 10) ? ':0' + minutes : ':' + minutes;  // get minutes
                        timeValue += (seconds < 10) ? ':0' + seconds : ':' + seconds;  // get seconds
                        timeValue += (hours >= 12) ? ' P.M.' : ' A.M.';  // get AM/PM
                        
                        system.debug(InteractionDatetime + ' ' + timeValue);
                        
                        boolean Des_is_not_empty = (!string.isEmpty(c.Description));
                        boolean ListUploadDateNotEmpty = (c.Eloqua_List_Upload_Date__c != null);
                        EmailAddress = Contact_Ids.get(c.id).Email;
                        InteractionDatetime = InteractionDatetime + ' ' + timeValue;                    
                        Channel = (string.isEmpty(Contact_Ids.get(c.id).Last_Lead_Source_Channel__c)) ? 'None' : Contact_Ids.get(c.id).Last_Lead_Source_Channel__c;
                        Source = (string.isEmpty(Contact_Ids.get(c.id).Last_Lead_Source_Partner__c)) ? 'None' : Contact_Ids.get(c.id).Last_Lead_Source_Partner__c;
                        Tactic = (string.isEmpty(Contact_Ids.get(c.id).Last_Lead_Source_Content__c)) ? 'None' : Contact_Ids.get(c.id).Last_Lead_Source_Content__c;
                        Action = (string.isEmpty(Contact_Ids.get(c.id).Eloqua_Event_Status__c)) ? 'None' : Contact_Ids.get(c.id).Eloqua_Event_Status__c;
                        ContentOfferSerial = (string.isEmpty(c.Last_CO__c)) ? 'None' : c.Last_CO__c;
                        SFDC_Campaign_ID = (string.isEmpty(c.Last_SFDC_Campaign_ID__c)) ? 'None' : c.Last_SFDC_Campaign_ID__c;
                        val = c.Description;
                        system.debug('[Class] <multi_Interaction_logic> : Original - ' + c.Description);
                        system.debug('[Class] <multi_Interaction_logic> : Dates are different 2 = ' + UpdateRecord);
                        system.debug('[Class] <multi_Interaction_logic> : Dates are = ' + c.Eloqua_List_Upload_Date__c + ' : ' + oldList_Contact.get(c.id).Eloqua_List_Upload_Date__c);
                        if(ListUploadDateNotEmpty){
                            if(Des_is_not_empty && UpdateRecord){ 
                                randStr = 'ANN';
                                while (randStr.length() < 18) {
                                    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                                    randStr += chars.substring(idx, idx+1);
                                }
                                // If description field is not blank, insert string below //
                                String val2 = ',{"Email Address" : "'+EmailAddress+'","Unique ID" : "'+randStr+'","Content Offer Serial" : "'+ContentOfferSerial+'","Page Visit Datetime" : "'+PageVisitTime+'","Interaction Datetime" : "'+InteractionDatetime+'","Channel" : "'+Channel+'","Source" : "'+Source+'","Keyword" : "'+Keyword+'","Device" : "'+Device+'","Previous Page" : "'+PreviousPage+'","Tactic" : "'+Tactic+'","Action" : "'+Action+'","Form" : "'+Form+'","Form Count" : "'+FormCount+'","SFDC Campaign ID" : "'+SFDC_Campaign_ID+'","PPC Ad" : "'+PpcAd+'","PPC Ad Group" : "'+PpcAdGroup+'"}]'; 
                                c.Description = val.substring(0, val.length() - 1) + val2;
                                system.debug('[Class] <multi_Interaction_logic> : Description field is not empty');
                                system.debug('[Class] <multi_Interaction_logic> New:' + c.Description);
                                updateList_C.add(c);
                                
                            }
                            else if (!Des_is_not_empty && UpdateRecord){
                                randStr = 'ANN';
                                while (randStr.length() < 18) {
                                    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                                    randStr += chars.substring(idx, idx+1);
                                }
                                // If description field is blank, insert string below //
                                String val2 = '[{"Email Address" : "'+EmailAddress+'","Unique ID" : "'+randStr+'","Content Offer Serial" : "'+ContentOfferSerial+'","Page Visit Datetime" : "'+PageVisitTime+'","Interaction Datetime" : "'+InteractionDatetime+'","Channel" : "'+Channel+'","Source" : "'+Source+'","Keyword" : "'+Keyword+'","Device" : "'+Device+'","Previous Page" : "'+PreviousPage+'","Tactic" : "'+Tactic+'","Action" : "'+Action+'","Form" : "'+Form+'","Form Count" : "'+FormCount+'","SFDC Campaign ID" : "'+SFDC_Campaign_ID+'","PPC Ad" : "'+PpcAd+'","PPC Ad Group" : "'+PpcAdGroup+'"}]';
                                c.Description = val2;
                                system.debug('[Class] <multi_Interaction_logic> : Description field is empty');
                                system.debug('[Class] <multi_Interaction_logic> New:' + c.Description);
                                updateList_C.add(c);  
                            }
                        }
                    }
                    
                }
                if(updateList_L.size() > 0){
                    //update updateList_C;
                }
            }
       // }
    }
    
}