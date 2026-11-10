public with sharing class ScoringService {

    @AuraEnabled
    public static Integer score(String intent, Boolean injured, Boolean assetMatched) {
        Integer s = 0;
        if (intent == 'FIRE' || intent == 'GAS' || intent == 'MEDICAL' || intent == 'ASSAULT') {
            s += 35;
        }
        if (assetMatched == true) { s += 15; }
        if (injured == true) { s += 25; }
        return s;
    }
}