trigger SMAX_PS_Product on Product2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  SMAX_PS_Utility.executeHandler(new SMAX_PS_ProductTriggerHandler());
}