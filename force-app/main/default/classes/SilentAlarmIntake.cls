public with sharing class SilentAlarmIntake {
    public class Request {
        @InvocableVariable(required=true) public String stationCode;
    }
    public class Response {
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Create Silent Alarm Case')
    public static List<Response> create(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) {
            Response resp = new Response();
            List<Station__c> st = [SELECT Id, Status__c FROM Station__c WHERE Name = :r.stationCode LIMIT 1];
            if (st.isEmpty()) {
                resp.message = 'Unknown station ' + r.stationCode;
                out.add(resp);
                continue;
            }
            Case c = new Case(
                Subject = 'Silent alarm',
                Emergency_Type__c = 'ASSAULT',
                Station_ID__c = st[0].Id,
                Anonymous__c = true,
                Contains_PHI__c = false
            );
            insert c;
            resp.caseNumber = [SELECT CaseNumber FROM Case WHERE Id = :c.Id].CaseNumber;
            resp.message = (st[0].Status__c == 'Out of Service')
                ? 'Station out of service'
                : 'Created';
            out.add(resp);
        }
        return out;
    }
}