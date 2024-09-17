public class OrgLimitMonitor {
    
    // Method to fetch all governor limits
    @AuraEnabled
    public static String fetchGovernorLimits() {
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit fileStorage = limitsMap.get('FileStorageMB');
        System.debug('Limit Name: ' + fileStorage.getName());
        System.debug('Usage Value: ' + fileStorage.getValue());
        System.debug('Maximum Limit: ' + fileStorage.getLimit());
        return fileStorage.getName() + ' = ' + fileStorage.getValue() + ' / ' + fileStorage.getLimit() ;
    }
   
}
