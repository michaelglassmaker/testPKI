public class QuoteToExcelClass {

    public String Page {get; set;}
    public String OpenPageURL {get; set;}
    
    public void QuoteToExcelClass()
    {
        Page = '' ;
        OpenPageURL = '' ;
    }
    
    public void redirect()
    {
        if(Page == 'EBX')
        {
            OpenPageURL = 'http://10.42.1.76:9090/ebx-ui/ui-node/data/BCustomerMasterDataSpace/CustomerMasterDataSet/root/Customer?perkinelmer-mdm@LaunchSingleCustomerWorkflow/';
        }
    }


}