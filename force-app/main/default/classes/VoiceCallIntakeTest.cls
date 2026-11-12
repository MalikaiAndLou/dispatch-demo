@IsTest(SeeAllData=true)
private class VoiceCallIntakeTest {
    @IsTest static void createsCaseWithStation() {
        VoiceCallIntake.Request r = new VoiceCallIntake.Request();
        r.dnis = '4155550103';
        r.intent = 'FIRE';
        r.injured = false;

        List<VoiceCallIntake.Response> out =
            VoiceCallIntake.create(new List<VoiceCallIntake.Request>{ r });
        System.assertNotEquals(null, out[0].caseNumber);

        Case c = [SELECT Emergency_Type__c, Station_ID__c, Routing_Decision__c
                  FROM Case WHERE CaseNumber = :out[0].caseNumber];
        System.assertEquals('FIRE', c.Emergency_Type__c);
        System.assertNotEquals(null, c.Station_ID__c);
        System.assertNotEquals(null, c.Routing_Decision__c);
    }

    @IsTest static void createsCaseWithoutStation() {
        VoiceCallIntake.Request r = new VoiceCallIntake.Request();
        r.dnis = '4155559999';
        r.intent = 'FIRE';
        r.injured = true;

        List<VoiceCallIntake.Response> out =
            VoiceCallIntake.create(new List<VoiceCallIntake.Request>{ r });

        Case c = [SELECT Station_ID__c, Routing_Decision__c
                  FROM Case WHERE CaseNumber = :out[0].caseNumber];
        System.assertEquals(null, c.Station_ID__c);
        System.assertEquals('FIRE / DEFAULT / fallback', c.Routing_Decision__c);
    }
}