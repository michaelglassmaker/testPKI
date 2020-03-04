/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Configero_GridApp extends PowerLoader.Configero_Base {
    global List<System.SelectOption> objectList {
        get;
    }
    global List<List<System.SelectOption>> objectListMulti {
        get;
    }
    global Configero_GridApp() {

    }
    global Configero_GridApp(PowerLoader.Configero_Base cb) {

    }
    @RemoteAction
    global static void DeleteTemplate(String objectAPIName, Map<String,String> params) {

    }
    @RemoteAction
    global static List<SObject> getDrillUpIds(String objectAPIName, String field, List<Id> ids) {
        return null;
    }
    @RemoteAction
    global static Map<String,String> getIdsByCriteria(String objectAPIName, List<String> fields, Map<String,String> criteria, Integer pageSize) {
        return null;
    }
    global static Map<String,String> getIdsBySQL(String objectAPIName, List<String> fields, String whereClause, Integer pageSize) {
        return null;
    }
    global static Map<String,String> getIdsBySQL(String objectAPIName, List<String> fields, String whereClause, Integer pageSize, Boolean allRows) {
        return null;
    }
    @RemoteAction
    global static Map<String,String> getIds(String objectAPIName, List<String> fields, Boolean onlyMine, Integer pageSize) {
        return null;
    }
    @RemoteAction
    global static String getObjectMeta(String objectAPIName) {
        return null;
    }
    @RemoteAction
    global static String getObjectPicklistMeta(String objectAPIName, List<String> picklists) {
        return null;
    }
    @RemoteAction
    global static Map<String,Long> hasModifiedSince(String objectAPIName, Boolean onlyMine, Long ts) {
        return null;
    }
    @RemoteAction
    global static Id saveTemplateProper(String namespace, String objectAPIName, Map<String,String> params, List<Map<String,String>> fields) {
        return null;
    }
    @RemoteAction
    global static Id saveTemplateSpecial(String namespace, String specialAPIName, Map<String,String> params, List<Map<String,String>> fields) {
        return null;
    }
    @RemoteAction
    global static Id saveTemplate(String namespace, String objectAPIName, Map<String,String> params, List<Map<String,String>> fields) {
        return null;
    }
}
