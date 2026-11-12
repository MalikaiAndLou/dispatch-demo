/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-12-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class VoiceCallIntake {
    private static final String REASON_OUT_OF_SERVICE = 'OUT_OF_SERVICE';

    public class Request {
        @InvocableVariable(required=true) public String dnis;
        @InvocableVariable(required=true) public String intent;
        @InvocableVariable public Boolean injured;
    }

    public class Response {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String stationCode;
        @InvocableVariable public String stationStatus;
        @InvocableVariable public Integer score;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Create Voice Call Case')
    public static List<Response> create(List<Request> reqs) {
        List<Response> out = new List<Response>();
        if (reqs == null || reqs.isEmpty()) return out;

        List<StationResolver.Input> inputs = new List<StationResolver.Input>();
        for (Request r : reqs) {
            inputs.add(new StationResolver.Input(r == null ? null : r.dnis, null));
        }
        List<StationResolver.Result> results = StationResolver.resolveAll(inputs);

        List<Case> toInsert = new List<Case>();
        List<Integer> sourceIndex = new List<Integer>();
        List<Integer> scores = new List<Integer>();

        for (Integer i = 0; i < reqs.size(); i++) {
            Request r = reqs[i];
            if (r == null) continue;
            StationResolver.Result res = results[i];
            String intent = String.isBlank(r.intent) ? 'OTHER' : r.intent;
            Integer sc = ScoringService.score(intent, r.injured == true, res != null && res.stationId != null);

            Case c = new Case(
                Subject = 'Voice call: ' + intent,
                Emergency_Type__c = intent,
                Station_ID__c = res == null ? null : res.stationId,
                Score__c = sc,
                Anonymous__c = false,
                Contains_PHI__c = r.injured == true,
                SuppliedPhone = r.dnis
            );
            if (sc != null && sc >= 60) c.Priority = 'P0';

            toInsert.add(c);
            sourceIndex.add(i);
            scores.add(sc);
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
                resp.message = 'Null request';
            } else if (next < sourceIndex.size() && sourceIndex[next] == i) {
                StationResolver.Result res = results[i];
                resp.score = scores[next];
                resp.stationCode = res == null ? null : res.stationCode;
                resp.stationStatus = res == null ? null : res.stationStatus;

                if (!srs[next].isSuccess()) {
                    resp.message = 'ERROR: ' + srs[next].getErrors()[0].getMessage();
                } else {
                    resp.success = true;
                    resp.caseNumber = numById.get(toInsert[next].Id);
                    if (res == null || res.stationId == null) {
                        resp.message = 'No station for DNIS';
                    } else if (res.reason == REASON_OUT_OF_SERVICE) {
                        resp.message = 'Station out of service';
                    } else {
                        resp.message = 'Created';
                    }
                }
                next++;
            }
            out.add(resp);
        }
        return out;
    }
}