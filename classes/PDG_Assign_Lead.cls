public class PDG_Assign_Lead{
    public static String chars = '123456789';
    public static PDG_Public_Group_Names__c pubGrNames = PDG_Public_Group_Names__c.getInstance();
    public static List <Lead> storeRoutedLead = new List <Lead>();
    
   /* public static string createRandStr(){
        String randStr = '';
        while (randStr.length() < 2) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    } */
    public static void WarmRecords(map <String,List<Lead>> Records) {
        system.debug(LoggingLevel.Info,'%%getCpuTime()***'+Limits.getCpuTime());
        
        List <GroupMember> WarmAmericas = [SELECT Id, userorgroupid 
                                           FROM GroupMember WHERE group.Name = :pubGrNames.PDG_WARM_Americas__c];
        List <GroupMember> WarmEMEA = [SELECT Id, userorgroupid 
                                       FROM GroupMember WHERE group.Name = :pubGrNames.PDG_WARM_EMEA__c];
        List <GroupMember> WarmAPAC = [SELECT Id, userorgroupid 
                                       FROM GroupMember WHERE group.Name = :pubGrNames.PDG_WARM_APAC__c];
        
        
        
        Integer AmericasCount = WarmAmericas.size();
        Integer EMEACount = WarmEMEA.size();
        Integer APACCount = WarmAPAC.size();
        
        system.debug('[Class] <PDG_Assign_Lead> Map : ' + Records);    
        
        for(String s : Records.keySet()){
            for(Lead a :Records.get(s)){
                String randStr = '';
                while (randStr.length() < 2) {
                    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                    randStr += chars.substring(idx, idx+1);
                }
                system.debug('[Class] <PDG_Assign_Lead> randStr : ' + randStr);    
                
                if(AmericasCount > 0 && s.equals('Americas')){
                    Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), AmericasCount);
                    system.debug('[Class] <PDG_Assign_Lead> Warm Americas membersize : ' + AmericasCount); 
                    system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                    a.OwnerId = WarmAmericas[roundRobinIdx].UserOrGroupId;
                    a.Alert_First_Owner_Email__c = true;
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'Americas';
                    a.Is_PDG_Routing__c = true;//miss routing fix
                    storeRoutedLead.add(a);
                    system.debug('[Class] <PDG_Assign_Lead> UserId : ' + WarmAmericas[roundRobinIdx].UserOrGroupId);    
                }
                if(EMEACount > 0 && s.equals('EMEA')){
                    Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), EMEACount);
                    system.debug('[Class] <PDG_Assign_Lead> Warm EMEA membersize : ' + EMEACount); 
                    system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                    a.OwnerId = WarmEMEA[roundRobinIdx].UserOrGroupId;
                    a.Alert_First_Owner_Email__c = true;
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'EMEA';
                    a.Is_PDG_Routing__c = true;//miss routing fix
                    storeRoutedLead.add(a);
                    system.debug('[Class] <PDG_Assign_Lead> UserId : ' + WarmEMEA[roundRobinIdx].UserOrGroupId);                     
                }
                if(APACCount > 0 && s.equals('APAC')){
                    Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), APACCount);
                    system.debug('[Class] <PDG_Assign_Lead> Warm APAC membersize : ' + APACCount); 
                    system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                    a.OwnerId = WarmAPAC[roundRobinIdx].UserOrGroupId;
                    a.Alert_First_Owner_Email__c = true;
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'APAC';
                    a.Is_PDG_Routing__c = true;//miss routing fix
                    storeRoutedLead.add(a);
                    system.debug('[Class] <PDG_Assign_Lead> UserId : ' + WarmAPAC[roundRobinIdx].UserOrGroupId);                  
                }
                
            }
        }
        StampLeadOwner();
    }
    
    public static void HotRecords(map <String,List<Lead>> Records) {
        system.debug(LoggingLevel.Info,'%%getCpuTime()***'+Limits.getCpuTime());
        List <GroupMember> HotAmericas = [SELECT Id, userorgroupid 
                                          FROM GroupMember WHERE group.Name = :pubGrNames.PDG_HOT_Americas__c];
        List <GroupMember> HotEMEA = [SELECT Id, userorgroupid 
                                      FROM GroupMember WHERE group.Name = :pubGrNames.PDG_HOT_EMEA__c];
        List <GroupMember> HotAPAC = [SELECT Id, userorgroupid 
                                      FROM GroupMember WHERE group.Name = :pubGrNames.PDG_HOT_APAC__c];
        
        
        Integer AmericasCount = HotAmericas.size();
        Integer EMEACount = HotEMEA.size();
        Integer APACCount = HotAPAC.size();
        
        system.debug('[Class] <PDG_Assign_Lead> Map : ' + Records);    
        
        for(String s : Records.keySet()){
            for(Lead a :Records.get(s)){
                String randStr = '';
                while (randStr.length() < 2) {
                    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                    randStr += chars.substring(idx, idx+1);
                }
                
                system.debug('[Class] <PDG_Assign_Lead> randStr : ' + randStr);    
                if(AmericasCount > 0 && s.equals('Americas')){
                    Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), AmericasCount);
                    system.debug('[Class] <PDG_Assign_Lead> Hot Americas membersize : ' + AmericasCount); 
                    system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                    a.OwnerId = HotAmericas[roundRobinIdx].UserOrGroupId;
                    a.Alert_First_Owner_Email__c = true;
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'Americas';
                    a.Is_PDG_Routing__c = true;//miss routing fix
                    storeRoutedLead.add(a);
                    system.debug('[Class] <PDG_Assign_Lead> UserId : ' + HotAmericas[roundRobinIdx].UserOrGroupId);    
                }
                
                if(EMEACount > 0 && s.equals('EMEA')){
                    Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), EMEACount);
                    system.debug('[Class] <PDG_Assign_Lead> Hot EMEA membersize : ' + EMEACount); 
                    system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                    a.OwnerId = HotEMEA[roundRobinIdx].UserOrGroupId;
                    a.Alert_First_Owner_Email__c = true;
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'EMEA';
                    a.Is_PDG_Routing__c = true;//miss routing fix
                    storeRoutedLead.add(a);
                    system.debug('[Class] <PDG_Assign_Lead> UserId : ' + HotEMEA[roundRobinIdx].UserOrGroupId);                     
                }
                
                if(APACCount > 0 && s.equals('APAC')){
                    Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), APACCount);
                    system.debug('[Class] <PDG_Assign_Lead> Hot APAC membersize : ' + APACCount); 
                    system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                    a.OwnerId = HotAPAC[roundRobinIdx].UserOrGroupId;
                    a.Alert_First_Owner_Email__c = true;
                    a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'APAC';
                    a.Is_PDG_Routing__c = true;//miss routing fix
                    storeRoutedLead.add(a);
                    system.debug('[Class] <PDG_Assign_Lead> UserId : ' + HotAPAC[roundRobinIdx].UserOrGroupId);                     
                }
            }
        }
        StampLeadOwner();
        system.debug(LoggingLevel.Info,'%%getCpuTime()***'+Limits.getCpuTime());
    }
    public static void LDR_To_Dx(List <Lead> Records) {
        
        List <GroupMember> DX_LDRs = [SELECT Id, userorgroupid 
                                      FROM GroupMember WHERE group.Name = :pubGrNames.PDG_LDR_To_Dx__c]; 
        
        Integer DxLDRCount = DX_LDRs.size();
        
        for(Lead a : Records){
            String randStr = '';
            while (randStr.length() < 2) {
                Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                randStr += chars.substring(idx, idx+1);
            }
            
            system.debug('[Class] <PDG_Assign_Lead> randStr : ' + randStr);    
            
            if(DX_LDRs.size() > 0){
                Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), DxLDRCount);
                system.debug('[Class] <PDG_Assign_Lead> Dx membersize : ' + DxLDRCount); 
                system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                a.OwnerId = DX_LDRs[roundRobinIdx].UserOrGroupId;
                a.Alert_First_Owner_Email__c = true;
                a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'DX_LDR';
                a.Is_PDG_Routing__c = true;//miss routing fix
                storeRoutedLead.add(a);
                system.debug('[Class] <PDG_Assign_Lead> UserId : ' + DX_LDRs[roundRobinIdx].UserOrGroupId);    
            }
        }
        StampLeadOwner();
    }
    
    
    public static void GROW_LDR(List <Lead> Records) {
        
        List <GroupMember> GROW_LDRs = [SELECT Id, userorgroupid 
                                        FROM GroupMember WHERE group.Name =:pubGrNames.PDG_GROW_LDRs__c]; 
        
        Integer GROWLDRCount = GROW_LDRs.size();
        
        for(Lead a : Records){
            String randStr = '';
        while (randStr.length() < 2) {
                    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                    randStr += chars.substring(idx, idx+1);
                }
            system.debug('[Class] <PDG_Assign_Lead> randStr : ' + randStr);    
            if(GROW_LDRs.size() > 0){
                Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), GROWLDRCount);
                system.debug('[Class] <PDG_Assign_Lead> GROW membersize : ' + GROWLDRCount); 
                system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                a.OwnerId = GROW_LDRs[roundRobinIdx].UserOrGroupId;
                a.First_Owner_Changed__c = 'Yes';
                a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'GROW';
                a.Is_PDG_Routing__c = true;//miss routing fix
                if(a.PDG_Start_Time__c == null && a.Dispensation_SAI_Current_Status__c){
                    a.PDG_Start_Time__c = DateTime.now();
                    system.debug('[Class] <PDG_Routing> Time updated : ' + a.PDG_Start_Time__c);
                }                
                
                storeRoutedLead.add(a);
                system.debug('[Class] <PDG_Assign_Lead> UserId : ' + GROW_LDRs[roundRobinIdx].UserOrGroupId);    
            }
        }
        StampLeadOwner();
    } 
    
    
    public static void StampLeadOwner(){
        Map <Id,Id> manager_Id = new Map <Id,Id>();
        system.debug('[Class] <PDG_Assign_Lead> StampLeadOwner : ' + storeRoutedLead.size());    
        List <ID> storeIds = new List <ID>();
        
        if(storeRoutedLead.size() > 0){
            for(Lead ownerId : storeRoutedLead){
                if(!storeIds.contains(ownerId.ownerId)){
                    storeIds.add(ownerid.ownerId);
                    system.debug('[Class] <PDG_Assign_Lead> storeIds : ' + ownerId);
                }
            }
            
        }
        
        if(storeIds.size() > 0){
            system.debug('[Class] <PDG_Assign_Lead> storeIds : ' + storeIds.size());    
            Map <Id, User> us = new Map <Id, User>([Select id, Name From User where id=:storeIds]);
            system.debug('[Class] <PDG_Assign_Lead> User : ' + us);    
            
            for(Lead a : storeRoutedLead){          
                if(string.isEmpty(a.Lead_Owner_LDR_QL__c)){
                    system.debug('[Class] <PDG_Assign_Lead> Lead_Owner_LDR_QL__c : ' + us.get(a.ownerId).Name);    
                    a.Lead_Owner_LDR_QL__c = us.get(a.ownerId).Name;
                }
            }
        }
        system.debug(LoggingLevel.Info,'%%getCpuTime()***'+Limits.getCpuTime());
        
    }
    
    
}