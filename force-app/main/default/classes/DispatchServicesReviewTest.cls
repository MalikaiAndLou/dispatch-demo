/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-12-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
private class DispatchServicesReviewTest {
    @TestSetup static void setup() {
        insert new Building__c(Name = 'ZZ-BLDG');
    }

    private static Id bldg() {
        return [SELECT Id FROM Building__c WHERE Name = 'ZZ-BLDG' LIMIT 1].Id;
    }

    @IsTest static void nonNumericDnisDoesNotMatchJunkStation() {
        insert new Station__c(
            Name = 'ZZ-JUNK',
            DNIS__c = 'n/a',
            Status__c = 'In Service',
            Zone_Code__c = 'MB-03',
            Building__c = bldg()
        );

        Test.startTest();
        StationResolver.Result r = StationResolver.resolve('+', null);
        Test.stopTest();

        System.assertEquals('UNKNOWN', r.reason, 'a bare + must not match a junk DNIS');
    }

    @IsTest static void duplicateDnisReportsAmbiguous() {
        Id b = bldg();
        insert new List<Station__c>{
            new Station__c(Name = 'ZZ-DUP-A', DNIS__c = '4155550199', Status__c = 'In Service',
                Zone_Code__c = 'MB-03', Building__c = b),
            new Station__c(Name = 'ZZ-DUP-B', DNIS__c = '4155550199', Status__c = 'In Service',
                Zone_Code__c = 'MB-03', Building__c = b)
        };

        Test.startTest();
        StationResolver.Result r = StationResolver.resolve('4155550199', null);
        Test.stopTest();

        System.assertEquals('AMBIGUOUS_DNIS', r.reason);
        System.assertEquals(false, r.resolved);
    }
}