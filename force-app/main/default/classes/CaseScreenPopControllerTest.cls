@IsTest
private class CaseScreenPopControllerTest {
    @TestSetup static void setup() {
        insert new Building__c(Name = 'ZZ-POP');
    }

    @IsTest static void returnsPanelWithStation() {
        Id b = [SELECT Id FROM Building__c WHERE Name = 'ZZ-POP' LIMIT 1].Id;
        Station__c s = new Station__c(Name = 'ZZ-POP-STN', Zone_Code__c = 'MB-03', Building__c = b, Status__c = 'In Service');
        insert s;
        Case c = new Case(Subject = 'pop', Emergency_Type__c = 'FIRE', Station_ID__c = s.Id);
        insert c;

        Test.startTest();
        CaseScreenPopController.Panel p = CaseScreenPopController.getPanel(c.Id);
        Test.stopTest();

        System.assertEquals('ZZ-POP-STN', p.stationCode);
        System.assertEquals(c.Id, p.caseId);
    }

    @IsTest static void returnsPanelWithoutStation() {
        Case c = new Case(Subject = 'pop2', Emergency_Type__c = 'FIRE');
        insert c;

        Test.startTest();
        CaseScreenPopController.Panel p = CaseScreenPopController.getPanel(c.Id);
        Test.stopTest();

        System.assertNotEquals(null, p);
        System.assertEquals(null, p.stationCode);
    }

    @IsTest static void throwsOnBadId() {
        try {
            CaseScreenPopController.getPanel(null);
            System.assert(false, 'expected exception');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }
}