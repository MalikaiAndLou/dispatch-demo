/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-12-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest(SeeAllData=true)
private class VoiceCallIntakeBulkTest {
    @IsTest static void handlesTwoHundredCallsInOneTransaction() {
        List<VoiceCallIntake.Request> reqs = new List<VoiceCallIntake.Request>();
        for (Integer i = 0; i < 200; i++) {
            VoiceCallIntake.Request r = new VoiceCallIntake.Request();
            r.dnis = '4155550103';
            r.intent = 'FIRE';
            r.injured = false;
            reqs.add(r);
        }

        Test.startTest();
        List<VoiceCallIntake.Response> out = VoiceCallIntake.create(reqs);
        Test.stopTest();

        System.assertEquals(200, out.size(), 'exactly one response per request');
        Set<String> nums = new Set<String>();
        for (VoiceCallIntake.Response resp : out) {
            System.assertNotEquals(null, resp.caseNumber, 'every request creates a case');
            nums.add(resp.caseNumber);
        }
        System.assertEquals(200, [SELECT COUNT() FROM Case WHERE CaseNumber IN :nums]);
    }
}