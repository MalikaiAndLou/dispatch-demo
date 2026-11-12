public with sharing class SilentAlarmIntake {
    private static final String STATUS_OUT_OF_SERVICE = 'Out of Service';

    public class Request {
        @InvocableVariable(required=true) public String stationCode;
    }

    public class Response {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Create Silent Alarm Case')
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

        List<Case> toInsert = new List<Case>();
        List<Integer> sourceIndex = new List<Integer>();
        for (Integer i = 0; i < reqs.size(); i++) {
            Request r = reqs[i];
            Station__c s = (r == null || String.isBlank(r.stationCode)) ? null : byName.get(r.stationCode.trim());
            if (s == null) continue;
            toInsert.add(new Case(
                Subject = 'Silent alarm',
                Emergency_Type__c = 'ASSAULT',
                Station_ID__c = s.Id,
                Anonymous__c = true,
                Contains_PHI__c = false
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

            if (r == null || String.isBlank(r.stationCode)) {
                resp.message = 'Unknown station ' + (r == null ? null : r.stationCode);
            } else if (next < sourceIndex.size() && sourceIndex[next] == i) {
                Station__c s = byName.get(r.stationCode.trim());
                if (!srs[next].isSuccess()) {
                    resp.message = 'ERROR: ' + srs[next].getErrors()[0].getMessage();
                } else {
                    resp.success = true;
                    resp.caseNumber = numById.get(toInsert[next].Id);
                    resp.message = (s != null && s.Status__c == STATUS_OUT_OF_SERVICE)
                        ? 'Station out of service' : 'Created';
                }
                next++;
            } else {
                resp.message = 'Unknown station ' + r.stationCode;
            }
            out.add(resp);
        }
        return out;
    }
}