@IsTest(SeeAllData=true)
private class AgentEmergencyIntakeTest {
    @IsTest static void createsWithStation() {
        AgentEmergencyIntake.Request r = new AgentEmergencyIntake.Request();
        r.intent = 'FIRE';
        r.stationCode = 'MB-GH-VS01';
        r.injured = false;

        List<AgentEmergencyIntake.Response> out =
            AgentEmergencyIntake.create(new List<AgentEmergencyIntake.Request>{ r });

        Case c = [SELECT OwnerId, Routing_Decision__c FROM Case WHERE CaseNumber = :out[0].caseNumber];
        System.assertEquals('FIRE / MB-03 / exact', c.Routing_Decision__c);
    }
}