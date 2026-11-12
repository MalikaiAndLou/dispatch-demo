public with sharing class AgentEmergencyIntake {
    private static final String DEFAULT_INTENT = 'OTHER';
    private static final String STATUS_OUT_OF_SERVICE = 'Out of Service';

    public class Request {
        @InvocableVariable public String intent;
        @InvocableVariable public String stationCode;
        @InvocableVariable public String callerNumber;
        @InvocableVariable public Boolean injured;
    }

    public class Response {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String summary;
    }

    @InvocableMethod(label='Create Emergency Case from Agent')
    public static List<Response> create(List<Request> reqs) {
        List<Response> out = new List<Response>();
        if (reqs == null || reqs.isEmpty()) return out;

        Set<String> codes = new Set<String>();
        for (Request r : reqs) {
            if (r != null && String.isNotBlank(r.stationCode)) codes.add(r.stationCode.trim());
        }
        Map<String, Station__c> byName = new Map<String, Station__c>();
        if (!codes.isEmpty()) {
            for (Station__c s : [SELECT Id, Name, Status__c FROM Station__c WHERE Name IN :codes ORDER BY Name]) {
                byName.put(s.Name, s);
            }
        }

        List<StationResolver.Input> fbIn = new List<StationResolver.Input>();
        List<Integer> fbIdx = new List<Integer>();
        for (Integer i = 0; i < reqs.size(); i++) {
            Request r = reqs[i];
            if (r == null) continue;
            Boolean matched = String.isNotBlank(r.stationCode) && byName.containsKey(r.stationCode.trim());
            if (!matched && String.isNotBlank(r.callerNumber)) {
                fbIn.add(new StationResolver.Input(r.callerNumber, null));
                fbIdx.add(i);
            }
        }
        List<StationResolver.Result> fbRes = StationResolver.resolveAll(fbIn);

        Map<Integer, Station__c> resolved = new Map<Integer, Station__c>();
        for (Integer i = 0; i < reqs.size(); i++) {
            Request r = reqs[i];
            if (r != null && String.isNotBlank(r.stationCode) && byName.containsKey(r.stationCode.trim())) {
                resolved.put(i, byName.get(r.stationCode.trim()));
            }
        }
        for (Integer n = 0; n < fbIdx.size(); n++) {
            StationResolver.Result res = fbRes[n];
            if (res != null && res.stationId != null) {
                resolved.put(fbIdx[n], new Station__c(Id = res.stationId, Status__c = res.stationStatus));
            }
        }

        List<Case> toInsert = new List<Case>();
        List<Integer> sourceIndex = new List<Integer>();
        for (Integer i = 0; i < reqs.size(); i++) {
            Request r = reqs[i];
            if (r == null) continue;
            String intent = String.isBlank(r.intent) ? DEFAULT_INTENT : r.intent;
            Station__c s = resolved.get(i);
            toInsert.add(new Case(
                Subject = intent + ' - agent intake',
                Emergency_Type__c = intent,
                Station_ID__c = s == null ? null : s.Id,
                Anonymous__c = false,
                Contains_PHI__c = r.injured == true,
                SuppliedPhone = r.callerNumber
            ));
            sourceIndex.add(i);
        }

        Database.SaveResult[] srs = toInsert.isEmpty()
            ? new List<Database.SaveResult>()
            : Database.insert(toInsert, false);

        Set<Id> okIds = new Set<Id>();
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) okIds.add(sr.getId());
        }
        Map<Id, String> numById = new Map<Id, String>();
        if (!okIds.isEmpty()) {
            for (Case c : [SELECT Id, CaseNumber FROM Case WHERE Id IN :okIds]) {
                numById.put(c.Id, c.CaseNumber);
            }
        }

        Integer next = 0;
        for (Integer i = 0; i < reqs.size(); i++) {
            Request r = reqs[i];
            Response resp = new Response();
            resp.success = false;

            if (r == null) {
                resp.summary = 'ERROR: null request';
            } else if (next < sourceIndex.size() && sourceIndex[next] == i) {
                Station__c s = resolved.get(i);
                if (!srs[next].isSuccess()) {
                    resp.summary = 'ERROR: ' + srs[next].getErrors()[0].getMessage();
                } else {
                    resp.success = true;
                    resp.caseNumber = numById.get(toInsert[next].Id);
                    resp.summary = 'Case ' + resp.caseNumber + ' created. Station '
                        + (s == null ? 'not resolved'
                           : (s.Status__c == STATUS_OUT_OF_SERVICE ? 'out of service' : s.Status__c));
                }
                next++;
            }
            out.add(resp);
        }
        return out;
    }
}