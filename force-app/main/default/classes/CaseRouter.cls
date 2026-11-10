public with sharing class CaseRouter {
    private static final String DEFAULT_ZONE = 'DEFAULT';

    public static void route(List<Case> newCases) {
        Map<Id, Case> source = new Map<Id, Case>();
        Set<Id> stationIds = new Set<Id>();
        for (Case c : newCases) {
            if (c.Routed_Timestamp__c == null) {
                source.put(c.Id, c);
                if (c.Station_ID__c != null) stationIds.add(c.Station_ID__c);
            }
        }
        if (source.isEmpty()) return;

        Map<Id, String> zoneByStation = new Map<Id, String>();
        for (Station__c s : [SELECT Id, Zone_Code__c FROM Station__c WHERE Id IN :stationIds]) {
            zoneByStation.put(s.Id, s.Zone_Code__c);
        }

        Map<String, Routing_Map__mdt> exact = new Map<String, Routing_Map__mdt>();
        Map<String, Routing_Map__mdt> fallback = new Map<String, Routing_Map__mdt>();
        for (Routing_Map__mdt r : [SELECT Intent__c, Zone_Code__c, Queue_Id__c, Priority__c
                                   FROM Routing_Map__mdt WHERE Active__c = true]) {
            if (r.Zone_Code__c == DEFAULT_ZONE) {
                fallback.put(r.Intent__c, r);
            } else {
                exact.put(r.Intent__c + '|' + r.Zone_Code__c, r);
            }
        }

        List<Case> updates = new List<Case>();
        for (Case c : source.values()) {
            String zone = zoneByStation.get(c.Station_ID__c);
            Routing_Map__mdt r = null;
            if (zone != null) r = exact.get(c.Emergency_Type__c + '|' + zone);
            if (r == null) r = fallback.get(c.Emergency_Type__c);

            Case upd = new Case(Id = c.Id, Routed_Timestamp__c = System.now());
            if (r == null) {
                upd.Routing_Decision__c = 'NO ROUTE';
            } else {
                if (r.Queue_Id__c != null) upd.OwnerId = Id.valueOf(r.Queue_Id__c);
                if (r.Priority__c != null) upd.Priority = r.Priority__c;
                upd.Routing_Decision__c = c.Emergency_Type__c + ' / '
                    + (zone == null ? DEFAULT_ZONE : zone);
            }
            updates.add(upd);
        }
        update updates;
    }
}