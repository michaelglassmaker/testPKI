/**
 * Created by frankvanloon on 2018-11-28.
 */
trigger SMAX_PS_Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SMAX_PS_Utility.executeHandler(new SMAX_PS_AccountTriggerHandler());
}