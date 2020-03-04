//Generated by wsdl2apex

public class SalesRepLookUpService {
    public class salesRepLookupV2Response {
        public SalesRepLookUpService.SalesReps2[] SalesReps2;
        private String[] SalesReps2_type_info = new String[]{'SalesReps2','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup','false','false'};
        private String[] field_order_type_info = new String[]{'SalesReps2'};
    }
    public class salesRepLookupV2 {
        public String country;
        public String fivedigitzip;
        public String productline;
        private String[] country_type_info = new String[]{'country','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] fivedigitzip_type_info = new String[]{'fivedigitzip','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] productline_type_info = new String[]{'productline','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup','false','false'};
        private String[] field_order_type_info = new String[]{'country','fivedigitzip','productline'};
    }
    public class SalesReps2 {
        public String AssignLevel;
        public String SalesRepName;
        public String SalesRepEmail;
        public String SalesRepsManagerName;
        public String SalesRepsManagerEmail;
        public String AccountName;
        public String ProductLine;
        private String[] AssignLevel_type_info = new String[]{'AssignLevel','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] SalesRepName_type_info = new String[]{'SalesRepName','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] SalesRepEmail_type_info = new String[]{'SalesRepEmail','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] SalesRepsManagerName_type_info = new String[]{'SalesRepsManagerName','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] SalesRepsManagerEmail_type_info = new String[]{'SalesRepsManagerEmail','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] AccountName_type_info = new String[]{'AccountName','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] ProductLine_type_info = new String[]{'ProductLine','http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup','false','false'};
        private String[] field_order_type_info = new String[]{'AssignLevel','SalesRepName','SalesRepEmail','SalesRepsManagerName','SalesRepsManagerEmail','AccountName','ProductLine'};
    }
    public class WebServices_PESFDCSalesRepLookup_Port {
        public String endpoint_x = 'https://integrationserver.perkinelmer.com:5552/ws/WebServices.PESFDCSalesRepLookup/WebServices_PESFDCSalesRepLookup_Port';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup', 'SalesRepLookUpService'};
        public SalesRepLookUpService.SalesReps2[] salesRepLookupV2(String country,String fivedigitzip,String productline) {
            SalesRepLookUpService.salesRepLookupV2 request_x = new SalesRepLookUpService.salesRepLookupV2();
            request_x.country = country;
            request_x.fivedigitzip = fivedigitzip;
            request_x.productline = productline;
            SalesRepLookUpService.salesRepLookupV2Response response_x;
            Map<String, SalesRepLookUpService.salesRepLookupV2Response> response_map_x = new Map<String, SalesRepLookUpService.salesRepLookupV2Response>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'WebServices_PESFDCSalesRepLookup_Binder_salesRepLookupV2',
              'http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',
              'salesRepLookupV2',
              'http://integrationserver.perkinelmer.com/WebServices:PESFDCSalesRepLookup',
              'salesRepLookupV2Response',
              'SalesRepLookUpService.salesRepLookupV2Response'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SalesReps2;
        }
    }
}