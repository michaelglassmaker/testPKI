/*
Name        : LaunchCPQExt
Author      : Anila Khwaja
Date        : 21-Nov-2013
Version     : 1.0
Description : This class is used to redirect user to CPQ Opportunity page
*/
public with sharing class LaunchCPQExt
{
    /**************************PROPERTIES*************************************/
    public Opportunity objOpp
    {
        get;
        set;
    }
    private String fpServer
    {
        get;
        set;
    }
    private final string SERVER_PARAM = 'server';
    private String error_msg
    {
        get;
        set;
    }
    /**************************Constants*************************************/
    private final string Global_Setting_Record_Not_Found = 'Global settings does not hold any value for {0}. Please provide a valid value.';
    private final string FPX_CPQ_SANDBOX_URL = 'CPQ-Sandbox-Server';
    private final string FPX_CPQ_PRODUCTION_URL = 'CPQ-Production-Server';
    private final string PRODUCTION = 'Production';
    private final string SANDBOX = 'Sandbox';
    private final string ACCOUNT_OBJ = 'Account';
    private final string OPP_OBJ = 'Opportunity';
    
    
    /**************************METHODS*************************************/
    
    
    public LaunchCPQExt(ApexPages.StandardController controller)
    {
        if(controller != null)
        {
            objOpp = [Select Id, Name, firepond__Context_Variables__c from Opportunity where Id = : controller.getRecord().id];
        }
    }
    
    public void GetServerURL()
    {
        // Get Server URL fpServer 
        string pServer = '';
        pServer = ApexPages.currentPage().getParameters().get(SERVER_PARAM);
        if(pServer == null) // Production is default server
            pServer = PRODUCTION; // Production is default server
        fpServer = '';
        String ErrorMsgProduction = String.format(Global_Setting_Record_Not_Found, new String[]
        {
            FPX_CPQ_PRODUCTION_URL
        });
        String ErrorMsgSandBox = String.format(Global_Setting_Record_Not_Found, new String[]
        {
            FPX_CPQ_SANDBOX_URL
        });
        List < firepond__Global_Setting__c > listOfGlobalSetting = null;
        if(pServer == PRODUCTION)
        {
            listOfGlobalSetting = [Select Id, firepond__Setting_Value__c From firepond__Global_Setting__c Where Name = : FPX_CPQ_PRODUCTION_URL];
            if(listOfGlobalSetting.size() <= 0)
            {
                AddError(ErrorMsgProduction);
                error_msg = ErrorMsgProduction;
            }
            else if(listOfGlobalSetting.get(0).firepond__Setting_Value__c == null || String.IsBlank(listOfGlobalSetting.get(0).firepond__Setting_Value__c.trim()))
            {
                AddError(ErrorMsgProduction);
                error_msg = ErrorMsgProduction;
            }
            else
                fpServer = listOfGlobalSetting.get(0).firepond__Setting_Value__c.trim();
        }
        if(pServer == SANDBOX)
        {
            listOfGlobalSetting = [Select Id, firepond__Setting_Value__c From firepond__Global_Setting__c Where Name = : FPX_CPQ_SANDBOX_URL];
            if(listOfGlobalSetting.size() <= 0)
            {
                AddError(ErrorMsgSandBox);
                error_msg = ErrorMsgSandBox;
            }
            else if(listOfGlobalSetting.get(0).firepond__Setting_Value__c == null || String.IsBlank(listOfGlobalSetting.get(0).firepond__Setting_Value__c.trim()))
            {
                AddError(ErrorMsgSandBox);
                error_msg = ErrorMsgSandBox;
            }
            else
                fpServer = listOfGlobalSetting.get(0).firepond__Setting_Value__c.trim();
        }
    }
    

    private void buildContextVariables()
    {
        //List of context variable
        List < firepond__Context_Variable__c > listOfContextVariable = [Select Id, Name, firepond__Object__c, firepond__Variable_Value__c, firepond__Variable_Value_Field__c, firepond__Default__c From firepond__Context_Variable__c Limit 50000];
        
        if(listOfContextVariable.size() > 0)
        {
            //Fetch all variables
            map < Id, firepond__Context_Variable__c > mapOfFeild_FeildName = new map < Id, firepond__Context_Variable__c > ();
            string contextVariables = '';
            set < string > setOfAccountFields = new set < string > ();
            set < string > setOfOppFields = new set < string > ();
            Schema.DescribeFieldResult objFieldDescribe;
            
            //Get all allowed fields of Account Object
            for(Schema.SObjectField objField: Account.sobjectType.getDescribe().fields.getMap().values())
            {
                objFieldDescribe = objField.getDescribe();
                if(IsAllowedType(objFieldDescribe.getType(), objFieldDescribe.getLength()))
                {
                    setOfAccountFields.add(objFieldDescribe.getName());
                }
            }
            
            //Get all allowed fields of Opportunity Object
            for(Schema.SObjectField objField: Opportunity.sobjectType.getDescribe().fields.getMap().values())
            {
                objFieldDescribe = objField.getDescribe();
                if(IsAllowedType(objFieldDescribe.getType(), objFieldDescribe.getLength()))
                {
                    setOfOppFields.add(objFieldDescribe.getName());
                }
            }
            //make sures that single field is not added again in query
            set < string > setOfFields = new set < string > ();
            
            //create query to fetch all values from opp object      
            //   String queryOpp = 'Select Id, Name, firepond__Context_Variables__c ';
            
            String queryOpp = 'Select Id, Name, firepond__Context_Variables__c ';
            for(firepond__Context_Variable__c c: listOfContextVariable)
            {
                if(c.firepond__Variable_Value__c != null && c.firepond__Variable_Value__c != '')
                {
                    if(c.firepond__Object__c == OPP_OBJ && c.firepond__Variable_Value__c == 'Name')
                    {
                        mapOfFeild_FeildName.put(c.Id, c);
                        setOfFields.add(c.firepond__Variable_Value__c);
                        continue;
                    }
                    //Check if selected context variable field still exists in system 
                    if(c.firepond__Object__c == ACCOUNT_OBJ && setOfAccountFields.contains(c.firepond__Variable_Value__c))
                    {
                        //if this field is not already added in query
                        if(!setOfFields.contains(c.firepond__Variable_Value_Field__c))
                            queryOpp += ',' + c.firepond__Variable_Value_Field__c;
                        mapOfFeild_FeildName.put(c.Id, c);
                        setOfFields.add(c.firepond__Variable_Value_Field__c);
                    }
                    else if(c.firepond__Object__c == OPP_OBJ && setOfOppFields.contains(c.firepond__Variable_Value__c))
                    {
                        //if this field is not already added in query
                        if(!setOfFields.contains(c.firepond__Variable_Value__c))
                            queryOpp += ',' + c.firepond__Variable_Value__c;
                        mapOfFeild_FeildName.put(c.Id, c);
                        setOfFields.add(c.firepond__Variable_Value__c);
                    }
                }
            }
            queryOpp += ' From Opportunity Where Id = \'' + string.valueOf(objOpp.Id) + '\'';
            
            system.debug('ak:'+queryOpp);
            List < Opportunity > listOfOpp = Database.query(queryOpp);
            objOpp = listOfOpp.get(0);
            //get the values for context variable
            for(string cvID: mapOfFeild_FeildName.keySet())
            {
                firepond__Context_Variable__c c = mapOfFeild_FeildName.get(cvID);
                string variableValue = (c.firepond__Default__c != null) ? c.firepond__Default__c.replace('\"', '\\\"') : '';
                
                if(c.firepond__Object__c == OPP_OBJ && objOpp.get(c.firepond__Variable_Value__c) != null && objOpp.get(c.firepond__Variable_Value__c) != '')
                {
                    variableValue = String.valueOf(objOpp.get(c.firepond__Variable_Value__c)).replace('\"', '\\\"');
                }
                else if(c.firepond__Object__c == ACCOUNT_OBJ && objOpp.getSObject(c.firepond__Object__c) != null &&
                    objOpp.getSObject(c.firepond__Object__c).get(c.firepond__Variable_Value__c) != null &&
                    objOpp.getSObject(c.firepond__Object__c).get(c.firepond__Variable_Value__c) != '')
                {
                    variableValue = String.valueOf(objOpp.getSObject(c.firepond__Object__c).get(c.firepond__Variable_Value__c)).replace('\"', '\\\"');
                }
                contextVariables += '\"' + c.Name.replace('\"', '\\\"') + '\":\"' + variableValue + '\",';
            }
            //remove extra last comma
            objOpp.firepond__Context_Variables__c = (contextVariables.length() > 0) ? contextVariables.substring(0, contextVariables.length() - 1) : contextVariables;
            update objOpp;
        }
    }
    
    public PageReference action()
    {
        try
        {
            //Get URL From Global Setting, Production/Sandbox
            GetServerURL();
            //build context variables
            buildContextVariables();
            //Build the FPX connect string
            String url = buildFP_URL();
            if(url != '')
            {
                PageReference newPage = new PageReference(url);
                newPage.setRedirect(true);
                return newPage;
            }
            else
                AddError('Invalid URL is created "url:"' + url);
        }
        catch(Exception ex)
        {
            AddExceptionError(ex);
        }
        return null;
    }
    private String buildFP_URL()
    {
        String fpURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/home/home.jsp';
        if(fpServer != '')
        {
            //build the redirect url to FPX           
            String serverUrl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/services/Soap/u/28.0/' + UserInfo.getOrganizationId().substring(0, 15);
            String sessionId = UserInfo.getSessionId();
            String oName = EncodingUtil.urlEncode(objOpp.Name, 'UTF-8');
            fpURL = 'https://'+fpServer+'.fpx.com' + '/login/connect.do?destination=application&SfdcOpId=' + objOpp.Id + '&SfdcOpName=' + oName + '&SfdcServerURL=' + serverUrl + '&SfdcSessionID=' + sessionId;
        }
        else
        {
            //FPXUtility.AddError('Global settings does not hold any value for "FPX_CPQ_URL". Please provide valid value.');
            AddError(error_msg);
            return '';
        }
        return fpURL;
    }
    
    //Adding Error on page
    public static void AddError(String msg)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    }
    
         //Identifies if the type is allowed to show on page or not
    //used in LaunchCPQExt as well
    public static boolean IsAllowedType(Schema.DisplayType aDataType, Integer aFieldLength)
    {
        if(aDataType == Schema.Displaytype.String || 
            aDataType == Schema.Displaytype.Email || 
            aDataType == Schema.Displaytype.MultiPicklist || 
            aDataType == Schema.Displaytype.Picklist ||
            aDataType == Schema.Displaytype.URL ||
            aDataType == Schema.Displaytype.Date || 
            aDataType == Schema.Displaytype.DateTime ||
            aDataType == Schema.Displaytype.Double || 
            aDataType == Schema.Displaytype.Integer ||
            aDataType == Schema.Displaytype.Percent ||
            aDataType == Schema.Displaytype.Currency ||
            aDataType == Schema.Displaytype.Phone)
            return true;
        else
            return false;
    }
        
    public static void AddExceptionError(Exception ex)
    {
        AddError('Message : ' + ex.getMessage() + 
                '<br/> Line no : ' + ex.getLineNumber() + 
                '<br/> StackTraceString ' + ex.getStackTraceString() + 
                '<br/> Cause: ' + ex.getCause());        
    }
}