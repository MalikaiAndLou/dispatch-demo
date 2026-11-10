public with sharing class ScoreEmergencyAction {

    public class ScoreIn {
        @InvocableVariable public String intent;
        @InvocableVariable public Boolean injured;
        @InvocableVariable public Boolean assetMatched;
    }

    @InvocableMethod(label='Score Emergency')
    public static List<Integer> run(List<ScoreIn> reqs) {
        List<Integer> outs = new List<Integer>();
        for (ScoreIn req : reqs) {
            outs.add(ScoringService.score(req.intent, req.injured, req.assetMatched));
        }
        return outs;
    }
}