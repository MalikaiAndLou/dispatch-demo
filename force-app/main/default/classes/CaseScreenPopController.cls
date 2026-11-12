public with sharing class CaseScreenPopController {
    public class Panel {
        @AuraEnabled public Id caseId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String ownerName;
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
        if (caseId == null) throw handled('A case id is required.');
        List<Panel> panels = getPanels(new List<Id>{ caseId });
        if (panels.isEmpty()) throw handled('Case not found or not accessible.');
        return panels[0];
    }

    @AuraEnabled(cacheable=true)
    public static List<Panel> getPanels(List<Id> caseIds) {
        List<Panel> out = new List<Panel>();
        if (caseIds == null || caseIds.isEmpty()) return out;

        List<Case> rows;
        try {
            rows = [
                SELECT Id, CaseNumber, Status, Owner.Name, Emergency_Type__c, Priority,
                       Routing_Decision__c, Routed_Timestamp__c, Anonymous__c,
                       Contains_PHI__c, Score__c,
                       Station_ID__r.Name, Station_ID__r.Station_Class__c,
                       Station_ID__r.Status__c, Station_ID__r.Health_Status__c,
                       Station_ID__r.Zone_Code__c, Station_ID__r.Camera_ID__c,
                       Station_ID__r.Nearest_Entrance__c, Station_ID__r.Building__r.Name
                FROM Case
                WHERE Id IN :caseIds
                WITH USER_MODE
            ];
        } catch (System.QueryException e) {
            throw handled('Field access denied or case not found.');
        }

        for (Case c : rows) {
            Station__c s = c.Station_ID__r;
            Panel p = new Panel();
            p.caseId          = c.Id;
            p.caseNumber      = c.CaseNumber;
            p.status          = c.Status;
            p.ownerName       = c.Owner?.Name;
            p.emergencyType   = c.Emergency_Type__c;
            p.priority        = c.Priority;
            p.routingDecision = c.Routing_Decision__c;
            p.routedAt        = c.Routed_Timestamp__c;
            p.anonymous       = c.Anonymous__c;
            p.containsPhi     = c.Contains_PHI__c;
            p.score           = c.Score__c;
            if (s != null) {
                p.stationCode     = s.Name;
                p.stationClass    = s.Station_Class__c;
                p.stationStatus   = s.Status__c?.toUpperCase();
                p.healthStatus    = s.Health_Status__c?.toUpperCase();
                p.zoneCode        = s.Zone_Code__c;
                p.buildingName    = s.Building__r?.Name;
                p.cameraId        = s.Camera_ID__c;
                p.nearestEntrance = s.Nearest_Entrance__c;
            }
            out.add(p);
        }
        return out;
    }

    private static AuraHandledException handled(String msg) {
        AuraHandledException e = new AuraHandledException(msg);
        e.setMessage(msg);
        return e;
    }
}