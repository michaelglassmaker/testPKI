/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Configero_QueryPanelComponent extends PowerLoader.Configero_Base {
    global String qp_name {
        get;
        set;
    }
    global String qp_object {
        get;
        set;
    }
    global String query_panel_json {
        get;
    }
    global String query_panel_name {
        get;
        set;
    }
    global String query_panel_object {
        get;
        set;
    }
    global static Map<String,String> replacementValues;
    global String uid {
        get;
        set;
    }
    global Configero_QueryPanelComponent() {

    }
    global Configero_QueryPanelComponent(PowerLoader.Configero_Base cb) {

    }
    @RemoteAction
    global static Map<String,String> getIds(String objectAPIName, List<String> fields, Id query_panel_id, Map<String,String> criteria, Integer pageSize) {
        return null;
    }
    global static Map<String,String> getIds(String objectAPIName, List<String> fields, Id query_panel_id, Map<String,String> criteria, String additionalWhereClause, Integer pageSize) {
        return null;
    }
    @RemoteAction
    global static String getObjectQueryPanel(String object_name) {
        return null;
    }
    @RemoteAction
    global static String getQueryPanel(String qp_name) {
        return null;
    }
    global static String getWhereClause(String objectAPIName, Id query_panel_id, Map<String,String> criteria) {
        return null;
    }
    @RemoteAction
    global static Id saveTemplate(String namespace, Map<String,String> params, List<Map<String,String>> fields) {
        return null;
    }
}
