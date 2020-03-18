/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Configero_LayoutDisplay {
    global Map<String,String> fieldLabels {
        get;
        set;
    }
    global Set<String> forceEditable;
    global Set<String> forceNotEditable;
    global Set<String> forceNotRequired;
    global Set<String> forceRequired;
    global List<PowerLoader.Configero_LayoutDisplay.LayoutSection> layoutSections {
        get;
    }
    global List<PowerLoader.Configero_LayoutDisplay.LayoutSection> multirowLayoutSections {
        get;
    }
    global SObject obj {
        get;
        set;
    }
    global String objType {
        get;
    }
    global Configero_LayoutDisplay() {

    }
    global Configero_LayoutDisplay(SObject obj, String objType) {

    }
    global void loadLayout(SObject obj, String objType) {

    }
    global void setFieldEditable(String field) {

    }
    global void setFieldNotEditable(String field) {

    }
    global void setFieldNotRequired(String field) {

    }
    global void setFieldRequired(String field) {

    }
global class LayoutItem {
    global String fieldLabel {
        get;
    }
    global String fieldName {
        get;
    }
    global Boolean isEditable {
        get;
    }
    global Boolean isEmptySpace {
        get;
    }
    global Boolean isHtml {
        get;
    }
    global Boolean isNameField {
        get;
    }
    global Boolean isRequired {
        get;
    }
    global List<PowerLoader.Configero_LayoutDisplay.LayoutItem> subItems {
        get;
    }
    global String type {
        get;
    }
    global LayoutItem() {

    }
    global LayoutItem(String fieldName) {

    }
    global void addSubItem(PowerLoader.Configero_LayoutDisplay.LayoutItem item) {

    }
    global Boolean getIsCompound() {
        return null;
    }
    global void setFieldName(String fieldName) {

    }
    global void setIsEditable(Boolean isEditable) {

    }
}
global class LayoutRow {
    global List<PowerLoader.Configero_LayoutDisplay.LayoutItem> items {
        get;
    }
    global LayoutRow() {

    }
    global void addItem(PowerLoader.Configero_LayoutDisplay.LayoutItem item) {

    }
    global Boolean hasSomething() {
        return null;
    }
}
global class LayoutSection {
    global String header {
        get;
    }
    global Boolean isPersonAccount {
        get;
    }
    global Integer numCols {
        get;
    }
    global List<PowerLoader.Configero_LayoutDisplay.LayoutRow> rows {
        get;
    }
    global Boolean useHeading {
        get;
    }
    global LayoutSection() {

    }
    global LayoutSection(Integer numCols, String header, Boolean useHeading) {

    }
    global void addRow(PowerLoader.Configero_LayoutDisplay.LayoutRow row) {

    }
    global Boolean hasSomething() {
        return null;
    }
}
}
