public with sharing class AgentEmergencyIntake {
    public class Request {
        @InvocableVariable public String intent;
        @InvocableVariable public String stationCode;
        @InvocableVariable public String callerNumber;
        @InvocableVariable public Boolean injured;
    }
    public class Response {
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String summary;
    }

    @InvocableMethod(label='Create Emergency Case from Agent')
    public static List<Response> create(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) {
            Response resp = new Response();
            try {
                String intent = String.isBlank(r.intent) ? 'OTHER' : r.intent;

                Id stationId;
                String stationStatus;
                if (String.isNotBlank(r.stationCode)) {
                    List<Station__c> st = [SELECT Id, Status__c FROM Station__c WHERE Name = :r.stationCode LIMIT 1];
                    if (!st.isEmpty()) { stationId = st[0].Id; stationStatus = st[0].Status__c; }
                }
                if (stationId == null && String.isNotBlank(r.callerNumber)) {
                    StationResolver.Result res = StationResolver.resolve(r.callerNumber, null);
                    stationId = res.stationId;
                    stationStatus = res.stationStatus;
                }

                Case c = new Case(
                    Subject = intent + ' — agent intake',
                    Emergency_Type__c = intent,
                    Station_ID__c = stationId,
                    Anonymous__c = false,
                    Contains_PHI__c = r.injured == true
                );
                insert c;

                resp.caseNumber = [SELECT CaseNumber FROM Case WHERE Id = :c.Id].CaseNumber;
                resp.summary = 'Case ' + resp.caseNumber + ' created. Station '
                    + (stationId == null ? 'not resolved' : stationStatus);
            } catch (Exception e) {
                resp.summary = 'ERROR: ' + e.getTypeName() + ' — ' + e.getMessage();
            }
            out.add(resp);
        }
        return out;
    }
}