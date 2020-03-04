public class PDG_Assign_Contact {
    public static String chars = '123456789';
    public static PDG_Public_Group_Names__c pubGrNames = PDG_Public_Group_Names__c.getInstance();
    public static List <Contact> storeRoutedContact = new List <Contact>();
    
    public static void WarmRecords(map <String,List<Contact>> Records) {
        
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
        List <Contact> Lead_b  = new List <Contact>();
        for(String s : Records.keySet()){
            for(Contact a :Records.get(s)){
                
                String randStr = '';
                while (randStr.length() < 2) {
                    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                    randStr += chars.substring(idx, idx+1);
                }
                
                system.debug('[Class] <PDG_Assign_Lead> randStr : ' + randStr);    
                
                switch on s{
                    when 'Americas' {
                        if(WarmAmericas.size() > 0){
                            Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), AmericasCount);
                            system.debug('[Class] <PDG_Assign_Lead> Warm Americas membersize : ' + AmericasCount); 
                            system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                            a.OwnerId = WarmAmericas[roundRobinIdx].UserOrGroupId;
                            a.Alert_First_Owner_Email__c = true;
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'Americas';
                            a.Is_PDG_Routing__c = true;//miss routing fix
                            system.debug('[Class] <PDG_Assign_Lead> UserId : ' + WarmAmericas[roundRobinIdx].UserOrGroupId);    
                            storeRoutedContact.add(a);
                        }
                    }
                    when 'EMEA' {
                        if(WarmEMEA.size() > 0){
                            Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), EMEACount);
                            system.debug('[Class] <PDG_Assign_Lead> Warm EMEA membersize : ' + EMEACount); 
                            system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                            a.OwnerId = WarmEMEA[roundRobinIdx].UserOrGroupId;
                            a.Alert_First_Owner_Email__c = true;
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'EMEA';
                            a.Is_PDG_Routing__c = true;//miss routing fix
                            system.debug('[Class] <PDG_Assign_Lead> UserId : ' + WarmEMEA[roundRobinIdx].UserOrGroupId);                     
                            storeRoutedContact.add(a);
                        }
                    }
                    when 'APAC' {
                        if(WarmAPAC.size() > 0){
                            Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), APACCount);
                            system.debug('[Class] <PDG_Assign_Lead> Warm APAC membersize : ' + APACCount); 
                            system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                            a.OwnerId = WarmAPAC[roundRobinIdx].UserOrGroupId;
                            a.Alert_First_Owner_Email__c = true;
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'APAC';
                            a.Is_PDG_Routing__c = true;//miss routing fix
                            system.debug('[Class] <PDG_Assign_Lead> UserId : ' + WarmAPAC[roundRobinIdx].UserOrGroupId);                  
                            storeRoutedContact.add(a);
                        }
                    }
                }
            }
        }
        StampLeadOwner();
        
    }
    
    public static void HotRecords(map <String,List<Contact>> Records) {
        
        List <GroupMember> HotAmericas = [SELECT Id, userorgroupid 
                                          FROM GroupMember WHERE group.Name = :pubGrNames.PDG_HOT_Americas__c];
        List <GroupMember> HotEMEA = [SELECT Id, userorgroupid 
                                      FROM GroupMember WHERE group.Name = :pubGrNames.PDG_HOT_EMEA__c];
        List <GroupMember> HotAPAC = [SELECT Id, userorgroupid 
                                      FROM GroupMember WHERE group.Name = :pubGrNames.PDG_HOT_APAC__c];
        
        
        Integer AmericasCount = HotAmericas.size();
        Integer EMEACount = HotEMEA.size();
        Integer APACCount = HotAPAC.size();
        List <Contact> Lead_b  = new List <Contact>();
        system.debug('[Class] <PDG_Assign_Lead> Map : ' + Records);    
        
        for(String s : Records.keySet()){
            for(Contact a :Records.get(s)){
                String randStr = '';
                while (randStr.length() < 2) {
                    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                    randStr += chars.substring(idx, idx+1);
                }
                
                system.debug('[Class] <PDG_Assign_Lead> randStr : ' + randStr);    
                
                switch on s{
                    when 'Americas' {
                        if(HotAmericas.size() > 0){
                            Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), AmericasCount);
                            system.debug('[Class] <PDG_Assign_Lead> Hot Americas membersize : ' + AmericasCount); 
                            system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                            a.OwnerId = HotAmericas[roundRobinIdx].UserOrGroupId;
                            a.Alert_First_Owner_Email__c = true;
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'Americas';
                            a.Is_PDG_Routing__c = true;//miss routing fix
                            storeRoutedContact.add(a);
                            system.debug('[Class] <PDG_Assign_Lead> UserId : ' + HotAmericas[roundRobinIdx].UserOrGroupId);    
                        }
                    }
                    when 'EMEA' {
                        if(HotEMEA.size() > 0){
                            Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), EMEACount);
                            system.debug('[Class] <PDG_Assign_Lead> Hot EMEA membersize : ' + EMEACount); 
                            system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                            a.OwnerId = HotEMEA[roundRobinIdx].UserOrGroupId;
                            a.Alert_First_Owner_Email__c = true;
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'EMEA';
                            a.Is_PDG_Routing__c = true;//miss routing fix
                            storeRoutedContact.add(a);
                            system.debug('[Class] <PDG_Assign_Lead> UserId : ' + HotEMEA[roundRobinIdx].UserOrGroupId);                     
                        }
                    }
                    when 'APAC' {
                        if(HotAPAC.size() > 0){
                            Integer roundRobinIdx = Math.mod(Integer.valueOf(randStr), APACCount);
                            system.debug('[Class] <PDG_Assign_Lead> Hot APAC membersize : ' + APACCount); 
                            system.debug('[Class] <PDG_Assign_Lead> Index : ' + roundRobinIdx);    
                            a.OwnerId = HotAPAC[roundRobinIdx].UserOrGroupId;
                            a.Alert_First_Owner_Email__c = true;
                            a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'APAC';
                            a.Is_PDG_Routing__c = true;//miss routing fix
                            storeRoutedContact.add(a);
                            system.debug('[Class] <PDG_Assign_Lead> UserId : ' + HotAPAC[roundRobinIdx].UserOrGroupId);                     
                        }
                    }
                }
            }
        }
        StampLeadOwner();
    }
    
    
    public static void LDR_To_Dx(List <Contact> Records) {
        
        List <GroupMember> DX_LDRs = [SELECT Id, userorgroupid 
                                      FROM GroupMember WHERE group.Name = :pubGrNames.PDG_LDR_To_Dx__c]; 
        
        Integer DxLDRCount = DX_LDRs.size();
        List <Contact> Lead_b  = new List <Contact>();
        
        for(Contact a : Records){
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
                a.PDG_Routing_Tracking__c = a.PDG_Routing_Tracking__c + 'Dx';
                a.Is_PDG_Routing__c = true;//miss routing fix
                system.debug('[Class] <PDG_Assign_Lead> UserId : ' + DX_LDRs[roundRobinIdx].UserOrGroupId);    
                storeRoutedContact.add(a);
            }
        }
        StampLeadOwner();
    }
    
    
    
    
    public static void StampLeadOwner(){
        system.debug('[Class] <PDG_Assign_Lead> StampLeadOwner : ' + storeRoutedContact.size());    
        List <ID> storeIds = new List <ID>();
        
        if(storeRoutedContact.size() > 0){
            for(Contact ownerId : storeRoutedContact){
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
            
            for(Contact a : storeRoutedContact){          
                if(string.isEmpty(a.Lead_Owner_LDR_QL__c)){
                    system.debug('[Class] <PDG_Assign_Lead> Lead_Owner_LDR_QL__c : ' + us.get(a.ownerId).Name);    
                    a.Lead_Owner_LDR_QL__c = us.get(a.ownerId).Name;
                }
            }
        }
    }
    
}