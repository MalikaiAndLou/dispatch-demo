public with sharing class CaseRouter {
    private static final String DEFAULT_ZONE  = 'DEFAULT';
    private static final String NO_ROUTE      = 'NO ROUTE';
    private static final String KEY_EXACT     = 'EX|';
    private static final String KEY_FALLBACK  = 'FB|';

    @TestVisible private static Map<String, Routing_Map__mdt> routeCache;
    @TestVisible private static Set<String> validPriorities;

    public static void route(List<Case> newCases) {
        if (newCases == null || newCases.isEmpty()) return;

        Boolean isBefore = Trigger.isExecuting && Trigger.isBefore;
        Boolean isAfter  = Trigger.isExecuting && Trigger.isAfter;
        if (Trigger.isExecuting && !isBefore && !isAfter) return;

        List<Case> candidates = new List<Case>();
        Set<Id> stationIds = new Set<Id>();
        for (Case c : newCases) {
            if (c.Routed_Timestamp__c != null) continue;
            candidates.add(c);
            if (c.Station_ID__c != null) stationIds.add(c.Station_ID__c);
        }
        if (candidates.isEmpty()) return;

        Map<Id, String> zoneByStation = new Map<Id, String>();
        if (!stationIds.isEmpty()) {
            for (Station__c s : [SELECT Id, Zone_Code__c FROM Station__c WHERE Id IN :stationIds]) {
                zoneByStation.put(s.Id, normalize(s.Zone_Code__c));
            }
        }

        loadRoutes();

        List<Case> updates = new List<Case>();
        for (Case c : candidates) {
            String zone = zoneByStation.get(c.Station_ID__c);
            String intent = normalize(c.Emergency_Type__c);
            Routing_Map__mdt r = null;
            if (zone != null) r = routeCache.get(KEY_EXACT + intent + '|' + zone);
            if (r == null) r = routeCache.get(KEY_FALLBACK + intent);

            Case target = isBefore ? c : new Case(Id = c.Id);
            target.Routed_Timestamp__c = System.now();

            if (r == null) {
                target.Routing_Decision__c = NO_ROUTE;
            } else {
                Boolean exactMatch = zone != null
                    && routeCache.get(KEY_EXACT + intent + '|' + zone) != null;
                if (isValidQueue(r.Queue_Id__c)) target.OwnerId = r.Queue_Id__c;
                if (isValidPriority(r.Priority__c)) target.Priority = r.Priority__c;
                target.Routing_Decision__c = c.Emergency_Type__c + ' / '
                    + (zone == null ? DEFAULT_ZONE : zone)
                    + (exactMatch ? ' / exact' : ' / fallback');
            }

            if (isAfter) updates.add(target);
        }

        if (!isAfter || updates.isEmpty()) return;

        Database.SaveResult[] results = Database.update(updates, false);
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                System.debug(LoggingLevel.ERROR, 'Routing failed for ' + updates[i].Id + ': '
                    + results[i].getErrors()[0].getMessage());
            }
        }
    }

    private static void loadRoutes() {
        if (routeCache != null) return;
        routeCache = new Map<String, Routing_Map__mdt>();
        for (Routing_Map__mdt r : [SELECT Intent__c, Zone_Code__c, Queue_Id__c, Priority__c
                                   FROM Routing_Map__mdt WHERE Active__c = true]) {
            String k = String.isBlank(r.Zone_Code__c) || normalize(r.Zone_Code__c) == DEFAULT_ZONE
                ? KEY_FALLBACK + normalize(r.Intent__c)
                : KEY_EXACT + normalize(r.Intent__c) + '|' + normalize(r.Zone_Code__c);
            if (routeCache.containsKey(k)) {
                System.debug(LoggingLevel.WARN, 'Duplicate routing rule for ' + k);
            }
            routeCache.put(k, r);
        }
    }

    private static String normalize(String s) {
        return String.isBlank(s) ? null : s.trim().toUpperCase();
    }

    private static Boolean isValidQueue(String raw) {
        if (String.isBlank(raw) || (raw.length() != 15 && raw.length() != 18)) return false;
        try { Id.valueOf(raw); } catch (System.StringException e) { return false; }
        return true;
    }

    private static Boolean isValidPriority(String raw) {
        if (String.isBlank(raw)) return false;
        if (validPriorities == null) {
            validPriorities = new Set<String>();
            for (Schema.PicklistEntry p : Case.Priority.getDescribe().getPicklistValues()) {
                validPriorities.add(p.getValue());
            }
        }
        return validPriorities.contains(raw);
    }
}