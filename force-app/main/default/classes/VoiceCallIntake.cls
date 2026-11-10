public with sharing class VoiceCallIntake {
    public class Request {
        @InvocableVariable(required=true) public String dnis;
        @InvocableVariable(required=true) public String intent;
        @InvocableVariable public Boolean injured;
    }
    public class Response {
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String stationCode;
        @InvocableVariable public String stationStatus;
        @InvocableVariable public Integer score;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Create Voice Call Case')
    public static List<Response> create(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) {
            Response resp = new Response();
            StationResolver.Result res = StationResolver.resolve(r.dnis, null);
            Integer sc = ScoringService.score(r.intent, r.injured == true, res.stationId != null);

            resp.score = sc;
            resp.stationCode = res.stationCode;
            resp.stationStatus = res.stationStatus;

            Case c = new Case(
                Subject = 'Voice call: ' + r.intent,
                Emergency_Type__c = r.intent,
                Station_ID__c = res.stationId,
                Score__c = sc,
                Anonymous__c = false,
                Contains_PHI__c = r.injured == true
            );
            if (sc >= 60) c.Priority = 'P0';
            insert c;

            resp.caseNumber = [SELECT CaseNumber FROM Case WHERE Id = :c.Id].CaseNumber;
            if (res.stationId == null) {
                resp.message = 'No station for DNIS';
            } else if (res.reason == 'OUT_OF_SERVICE') {
                resp.message = 'Station out of service';
            } else {
                resp.message = 'Created';
            }
            out.add(resp);
        }
        return out;
    }
}