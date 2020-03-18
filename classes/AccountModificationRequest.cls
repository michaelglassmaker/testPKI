public class AccountModificationRequest {

public Account CurrentRecord;

     public string Name{get;set;}

public string city{get;set;}

    public string state{get;set;}

     public string street{get;set;}

     public string country{get;set;}

     public string postalcode{get;set;}

    public string Institute{get;set;}

        public string Department{get;set;}

    public string Comment{get;set;}

    public boolean showform{set;get;}
     public boolean showform1{set;get;}
public string Namecu;
public string citycu;
public string statecu;
public string streetcu;
public string countrycu;
public string postalcodecu;
public string Institutecu;
public string Departmentcu;
public string Commentcu;


 

    public AccountModificationRequest(ApexPages.StandardController controller) {

    showform=True;

      Account ctRec= (Account) controller.getRecord();

        CurrentRecord=[select ID,Name,ShippingCity,ShippingState,ShippingStreet,ShippingCountry,ShippingPostalCode,PKI_SAP_Name_3__c,PKI_SAP_Name_4__c,Comment__c,Account_Modification_flag__c, PKI_SAP_Customer_Number__c from Account where Id=:ctRec.ID limit 1];
        if (CurrentRecord.Account_Modification_flag__c==true)
        {
            showform1=True;
            showform=False;
            
        }
 
 
        

        Name=CurrentRecord.Name;

        city=CurrentRecord.ShippingCity;

        state=CurrentRecord.ShippingState;

        street=CurrentRecord.ShippingStreet;

         country=CurrentRecord.ShippingCountry;

          postalcode=CurrentRecord.ShippingPostalCode;

         Institute=CurrentRecord.PKI_SAP_Name_3__c;

         Department=CurrentRecord.PKI_SAP_Name_4__c;

                Comment=CurrentRecord.Comment__c;      
        
Namecu=CurrentRecord.Name;

citycu=CurrentRecord.ShippingCity;

statecu=CurrentRecord.ShippingState;

streetcu=CurrentRecord.ShippingStreet;

countrycu=CurrentRecord.ShippingCountry;

postalcodecu=CurrentRecord.ShippingPostalCode;

Institutecu=CurrentRecord.PKI_SAP_Name_3__c;

Departmentcu=CurrentRecord.PKI_SAP_Name_4__c;

Commentcu=CurrentRecord.Comment__c;
    }

    public Attachment file;

public Attachment getfile(){

file = new Attachment();

return file;

}

    Public void submit()

    {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Check button is clicked'));  
       CurrentRecord.Account_Modification_flag__c=true;
        update CurrentRecord;

                        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

 

        if (file!=null && file.name!=null && file.body!=null ){

           

        

        string recordid = System.currentPageReference().getParameters().get('id');
              
Attachment attach = new Attachment(

parentid = recordid,

 name = file.name,

body = file.body);
            

insert attach;
        
           

Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();

efa.setFileName(file.Name);

efa.setBody(file.Body);

fileAttachments.add(efa);

           

        }

        string toadd;

               string ccadd=UserInfo.getUserEmail();

 

 

// Use Organization Wide Address 

for(OrgWideEmailAddress owa : [select id,DisplayName, Address from OrgWideEmailAddress]) {

if(owa.displayName.contains(country)) toadd=owa.Address;

    

}      

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

String[] toAddresses = new String[] {toadd};

String[] ccAddresses = new String[] {ccadd};

mail.setToAddresses(toAddresses);

mail.setCcAddresses(ccAddresses);

mail.setReplyTo('support@acme.com');

mail.setSenderDisplayName('Salesforce Support');

mail.setSubject('Account Change : ' + CurrentRecord.Name);
String body = 'Hello Customer Care Team <br/><br/>' ;

body +='The following update to Customer Account Master Data for ' + CurrentRecord.Name + ' has requested for the following changes: <br/><br/><br/>';
if(Name!=Namecu && !string.isblank(Name) && !string.isblank(Namecu)){body +='Field Name:  Account Name <br/> Current Data: '+CurrentRecord.Name+'<br/>'+' Change To:  '+Name +'<br/><br/>';}
if(city!=citycu && !string.isblank(city) && !string.isblank(citycu)){body +='Field Name:  Shipping City <br/> Current Data: ' + CurrentRecord.ShippingCity +'<br/>'+' Change To:  '+city +'<br/><br/>';} 
if(state!=statecu && !string.isblank(state) && !string.isblank(statecu)){body += 'Field Name:  Shipping State <br/> Current Data:  ' + CurrentRecord.ShippingState +'<br/>'+' Change To:  '+state +'<br/><br/>';}
if(street!=streetcu && !string.isblank(street) && !string.isblank(streetcu)){body +='Field Name:  Shipping Street <br/> Current Data:  ' +CurrentRecord.ShippingStreet +'<br/>'+' Change To:  '+street +'<br/><br/>';}
if(country!=countrycu && !string.isblank(country) && !string.isblank(countrycu)){body += 'Field Name:  Shipping Country  <br/> Current Data:  ' +CurrentRecord.ShippingCountry +'<br/>'+' Change To:  '+country +'<br/><br/>';}
if(postalcode!=postalcodecu && !string.isblank(postalcode) && !string.isblank(postalcodecu)){body +='Field Name:  Shipping Postal Code <br/> Current Data:  ' +CurrentRecord.ShippingPostalCode +'<br/>'+' Change To:  '+postalcode +'<br/><br/>';}
if(Institute!=Institutecu && !string.isblank(Institute) && !string.isblank(Institutecu)){body +='Field Name:  Institute  <br/>  Current Data:  ' +CurrentRecord.PKI_SAP_Name_3__c +'<br/>'+' Change To:  '+Institute +'<br/><br/>' ;}
if(Department!=Departmentcu && !string.isblank(Department) && !string.isblank(Departmentcu)){body +='Field Name:  Department  <br/>  Current Data:  ' +CurrentRecord.PKI_SAP_Name_4__c +'<br/>'+' Change To:  '+Department +'<br/><br/>';}
if(Comment!=Commentcu){body +='Comment  : ' + Comment +'<br/>' ;}
mail.setHtmlBody(body);   
        if (fileAttachments!=null){
mail.setFileAttachments(fileAttachments);
        }
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        showform=false;

    }

 

 

    }