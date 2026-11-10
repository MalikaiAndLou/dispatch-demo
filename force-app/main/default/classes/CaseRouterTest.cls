@IsTest(SeeAllData=true)
private class CaseRouterTest {
    @IsTest static void routesFireInZone() {
        Station__c s = [SELECT Id FROM Station__c WHERE Name = 'MB-GH-VS01' LIMIT 1];
        Case c = new Case(Subject = 'fire', Emergency_Type__c = 'FIRE', Station_ID__c = s.Id);
        insert c;
        Case r = [SELECT Priority, Routing_Decision__c, Routed_Timestamp__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('FIRE / MB-03', r.Routing_Decision__c);
        System.assertNotEquals(null, r.Routed_Timestamp__c);
    }

    @IsTest static void defaultsWithoutStation() {
        Case c = new Case(Subject = 'fire no station', Emergency_Type__c = 'FIRE');
        insert c;
        Case r = [SELECT Routing_Decision__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('FIRE / DEFAULT', r.Routing_Decision__c);
    }
}