@IsTest(SeeAllData=true)
private class SilentAlarmIntakeTest {
    @IsTest static void createsAndRoutes() {
        SilentAlarmIntake.Request r = new SilentAlarmIntake.Request();
        r.stationCode = 'MB-BY-BL02';

        List<SilentAlarmIntake.Response> out =
            SilentAlarmIntake.create(new List<SilentAlarmIntake.Request>{ r });

        System.assertNotEquals(null, out[0].caseNumber);
        Case c = [SELECT Emergency_Type__c, Priority, OwnerId, Routing_Decision__c, Anonymous__c
                  FROM Case WHERE CaseNumber = :out[0].caseNumber];
        System.assertEquals('ASSAULT', c.Emergency_Type__c);
        System.assertEquals('P0', c.Priority);
        System.assertEquals(true, c.Anonymous__c);
        System.assertNotEquals(null, c.Routing_Decision__c);
    }
}