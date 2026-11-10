public with sharing class CaseScreenPopController {
    public class Panel {
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String emergencyType;
        @AuraEnabled public String priority;
        @AuraEnabled public String routingDecision;
        @AuraEnabled public DateTime routedAt;
        @AuraEnabled public Boolean anonymous;
        @AuraEnabled public Boolean containsPhi;
        @AuraEnabled public Decimal score;
        @AuraEnabled public String stationCode;
        @AuraEnabled public String stationClass;
        @AuraEnabled public String stationStatus;
        @AuraEnabled public String healthStatus;
        @AuraEnabled public String zoneCode;
        @AuraEnabled public String buildingName;
        @AuraEnabled public String cameraId;
        @AuraEnabled public String nearestEntrance;
    }

    @AuraEnabled(cacheable=true)
    public static Panel getPanel(Id caseId) {
        Case c = [
            SELECT CaseNumber, Emergency_Type__c, Priority, Routing_Decision__c,
                   Routed_Timestamp__c, Anonymous__c, Contains_PHI__c, Score__c, Station_ID__c
            FROM Case WHERE Id = :caseId
        ];
        Panel p = new Panel();
        p.caseNumber = c.CaseNumber;
        p.emergencyType = c.Emergency_Type__c;
        p.priority = c.Priority;
        p.routingDecision = c.Routing_Decision__c;
        p.routedAt = c.Routed_Timestamp__c;
        p.anonymous = c.Anonymous__c;
        p.containsPhi = c.Contains_PHI__c;
        p.score = c.Score__c;

        if (c.Station_ID__c != null) {
            Station__c s = [
                SELECT Name, Station_Class__c, Status__c, Health_Status__c, Zone_Code__c,
                       Camera_ID__c, Nearest_Entrance__c, Building__r.Name
                FROM Station__c WHERE Id = :c.Station_ID__c
            ];
            p.stationCode = s.Name;
            p.stationClass = s.Station_Class__c;
            p.stationStatus = s.Status__c;
            p.healthStatus = s.Health_Status__c;
            p.zoneCode = s.Zone_Code__c;
            p.buildingName = s.Building__r != null ? s.Building__r.Name : null;
            p.cameraId = s.Camera_ID__c;
            p.nearestEntrance = s.Nearest_Entrance__c;
        }
        return p;
    }
}