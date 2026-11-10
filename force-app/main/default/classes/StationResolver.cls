public with sharing class StationResolver {

    public class Result {
        @AuraEnabled public Boolean resolved;
        @AuraEnabled public String reason;
        @AuraEnabled public String matchedBy;
        @AuraEnabled public Id stationId;
        @AuraEnabled public String stationCode;
        @AuraEnabled public String stationClass;
        @AuraEnabled public String stationStatus;
        @AuraEnabled public String zoneCode;
        @AuraEnabled public String buildingName;
        @AuraEnabled public String nearestEntrance;
        @AuraEnabled public String cameraId;
    }

    private static String digitsOnly(String v) {
        return v == null ? null : v.replaceAll('[^0-9]', '');
    }

    @AuraEnabled(cacheable=true)
    public static Result resolve(String dnis, String dtmf) {
        Result r = new Result();
        r.resolved = false;

        Station__c s;
        String matchedBy;

        if (String.isNotBlank(dtmf)) {
            List<Station__c> byCode = [
                SELECT Id, Name, Station_Class__c, Status__c, Zone_Code__c,
                       Camera_ID__c, Nearest_Entrance__c, Building__r.Name
                FROM Station__c
                WHERE DTMF_Code__c = :dtmf
                LIMIT 1
            ];
            if (!byCode.isEmpty()) { s = byCode[0]; matchedBy = 'DTMF'; }
        }

        // Demo-scale normalisation: fetch and compare on digits.
        // Production should carry a normalised Text field instead.
        if (s == null && String.isNotBlank(dnis)) {
            String want = digitsOnly(dnis);
            for (Station__c cand : [
                SELECT Id, Name, Station_Class__c, Status__c, Zone_Code__c,
                       Camera_ID__c, Nearest_Entrance__c, DNIS__c, Building__r.Name
                FROM Station__c
                WHERE DNIS__c != null
            ]) {
                if (digitsOnly(cand.DNIS__c) == want) { s = cand; matchedBy = 'DNIS'; break; }
            }
        }

        if (s == null) {
            r.reason = 'UNKNOWN';
            return r;
        }

        r.matchedBy        = matchedBy;
        r.stationId        = s.Id;
        r.stationCode      = s.Name;
        r.stationClass     = s.Station_Class__c;
        r.stationStatus    = s.Status__c;
        r.zoneCode         = s.Zone_Code__c;
        r.buildingName     = s.Building__r != null ? s.Building__r.Name : null;
        r.nearestEntrance  = s.Nearest_Entrance__c;
        r.cameraId         = s.Camera_ID__c;

        if (s.Status__c == 'Out of Service') {
            r.reason = 'OUT_OF_SERVICE';
        } else {
            r.resolved = true;
            r.reason = 'OK';
        }
        return r;
    }
}