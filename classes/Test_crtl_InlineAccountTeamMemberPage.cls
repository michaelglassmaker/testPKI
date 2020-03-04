@isTest
private class Test_crtl_InlineAccountTeamMemberPage{
    @isTest private static void testClass(){
        Account testaccount = new Account(name='test account');
        insert testaccount ;
        ApexPages.StandardController sc = new ApexPages.standardController(testaccount);
        crtl_InlineAccountTeamMemberPage controllerclass=new crtl_InlineAccountTeamMemberPage(sc);
        crtl_InlineAccountTeamMemberPage.addMembership(testaccount.id, 'Sales Manager');
        crtl_InlineAccountTeamMemberPage.removeMembership(testaccount.id);
        controllerclass=new crtl_InlineAccountTeamMemberPage(sc);
        crtl_InlineAccountTeamMemberPage.addMembership(testaccount.id, 'Sales Manager');
        crtl_InlineAccountTeamMemberPage.changeMembershipRole(testaccount.id,'Account Manager');      
    }
}