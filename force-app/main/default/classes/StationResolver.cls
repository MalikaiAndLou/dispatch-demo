/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-12-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class StationResolver {
    private static final String STATUS_OUT_OF_SERVICE = 'Out of Service';
    private static final Integer SCAN_LIMIT = 5000;

    private static final String FIELDS =
        'Id, Name, Station_Class__c, Status__c, Zone_Code__c, DTMF_Code__c, ' +
        'Camera_ID__c, Nearest_Entrance__c, DNIS__c, Building__r.Name';

    public class Input {
        public String dnis;
        public String dtmf;
        public Input(String dnis, String dtmf) {
            this.dnis = dnis;
            this.dtmf = dtmf;
        }
    }

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
        List<Result> one = resolveAll(new List<Input>{ new Input(dnis, dtmf) });
        return (one == null || one.isEmpty()) ? fail('NO_INPUT') : one[0];
    }

    public static List<Result> resolveAll(List<Input> inputs) {
        List<Result> outs = new List<Result>();
        if (inputs == null || inputs.isEmpty()) {
            return outs;
        }

        Set<String> codes = new Set<String>();
        Set<String> wants = new Set<String>();
        for (Input i : inputs) {
            String c = digitsOnly(i == null ? null : i.dtmf);
            String w = digitsOnly(i == null ? null : i.dnis);
            if (String.isNotBlank(c)) codes.add(c);
            if (String.isNotBlank(w)) wants.add(w);
        }

        Map<String, List<Station__c>> byCode = new Map<String, List<Station__c>>();
        if (!codes.isEmpty()) {
            for (Station__c s : (List<Station__c>) Database.query(
                    'SELECT ' + FIELDS + ' FROM Station__c WHERE DTMF_Code__c IN :codes ORDER BY Name')) {
                bucket(byCode, digitsOnly(s.DTMF_Code__c), s);
            }
        }

        Map<String, List<Station__c>> byDnis = new Map<String, List<Station__c>>();
        if (!wants.isEmpty()) {
            for (Station__c s : (List<Station__c>) Database.query(
                    'SELECT ' + FIELDS + ' FROM Station__c WHERE DNIS__c != null ' +
                    'ORDER BY Name LIMIT ' + SCAN_LIMIT)) {
                String k = digitsOnly(s.DNIS__c);
                if (String.isBlank(k) || !wants.contains(k)) continue;
                bucket(byDnis, k, s);
            }
        }

        for (Input i : inputs) {
            outs.add(pick(i, byCode, byDnis));
        }
        return outs;
    }

    private static void bucket(Map<String, List<Station__c>> m, String k, Station__c s) {
        if (String.isBlank(k)) return;
        if (!m.containsKey(k)) m.put(k, new List<Station__c>());
        m.get(k).add(s);
    }

    private static Result pick(Input i, Map<String, List<Station__c>> byCode, Map<String, List<Station__c>> byDnis) {
        String c = digitsOnly(i == null ? null : i.dtmf);
        String w = digitsOnly(i == null ? null : i.dnis);

        Station__c s;
        String matchedBy;

        if (String.isNotBlank(c) && byCode.containsKey(c)) {
            List<Station__c> hits = byCode.get(c);
            if (hits.size() > 1) return fail('AMBIGUOUS_DTMF');
            s = hits[0];
            matchedBy = 'DTMF';
        }

        if (s == null && String.isNotBlank(w) && byDnis.containsKey(w)) {
            List<Station__c> hits = byDnis.get(w);
            if (hits.size() > 1) return fail('AMBIGUOUS_DNIS');
            s = hits[0];
            matchedBy = 'DNIS';
        }

        if (s == null) {
            return fail((String.isNotBlank(w) || String.isNotBlank(c)) ? 'UNKNOWN' : 'NO_INPUT');
        }

        Result r = new Result();
        r.resolved        = false;
        r.matchedBy       = matchedBy;
        r.stationId       = s.Id;
        r.stationCode     = s.Name;
        r.stationClass    = s.Station_Class__c;
        r.stationStatus   = s.Status__c;
        r.zoneCode        = s.Zone_Code__c;
        r.buildingName    = s.Building__r?.Name;
        r.nearestEntrance = s.Nearest_Entrance__c;
        r.cameraId        = s.Camera_ID__c;

        if (s.Status__c == STATUS_OUT_OF_SERVICE) {
            r.reason = 'OUT_OF_SERVICE';
        } else {
            r.resolved = true;
            r.reason = 'OK';
        }
        return r;
    }

    private static Result fail(String reason) {
        Result r = new Result();
        r.resolved = false;
        r.reason = reason;
        return r;
    }
}