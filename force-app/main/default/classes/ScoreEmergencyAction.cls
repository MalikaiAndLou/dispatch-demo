public with sharing class ScoreEmergencyAction {
    public class ScoreIn {
        @InvocableVariable public String intent;
        @InvocableVariable public Boolean injured;
        @InvocableVariable public Boolean assetMatched;
    }

    public class ScoreOut {
        @InvocableVariable public Boolean scored;
        @InvocableVariable public Integer score;
        @InvocableVariable public String band;
        @InvocableVariable public String reason;
    }

    @InvocableMethod(label='Score Emergency')
    public static List<ScoreOut> run(List<ScoreIn> reqs) {
        List<ScoreOut> outs = new List<ScoreOut>();
        if (reqs == null || reqs.isEmpty()) return outs;

        for (ScoreIn req : reqs) {
            ScoreOut o = new ScoreOut();
            o.scored = false;
            try {
                if (req == null) {
                    o.reason = 'NULL_REQUEST';
                } else {
                    Integer raw = ScoringService.score(
                        String.isBlank(req.intent) ? 'OTHER' : req.intent,
                        req.injured == true,
                        req.assetMatched == true
                    );
                    if (raw == null) {
                        o.reason = 'NO_SCORE';
                    } else {
                        o.scored = true;
                        o.score  = raw;
                        o.band   = bandFor(raw);
                        o.reason = 'OK';
                    }
                }
            } catch (Exception e) {
                o.scored = false;
                o.reason = 'EXCEPTION';
                System.debug(LoggingLevel.ERROR, 'Scoring failed: ' + e.getTypeName() + ' - ' + e.getMessage());
            }
            outs.add(o);
        }
        return outs;
    }

    private static String bandFor(Integer score) {
        if (score >= 8) return 'P1';
        if (score >= 5) return 'P2';
        if (score >= 3) return 'P3';
        return 'P4';
    }
}