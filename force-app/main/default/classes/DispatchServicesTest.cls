@IsTest(SeeAllData=true)
private class DispatchServicesTest {

    @IsTest
    static void resolvesKnownStation() {
        StationResolver.Result r = StationResolver.resolve('4155550103', null);
        System.assertEquals('OK', r.reason);
        System.assertEquals('MB-GH-VS01', r.stationCode);
        System.assertNotEquals(null, r.buildingName);
    }

    @IsTest
    static void flagsOutOfService() {
        StationResolver.Result r = StationResolver.resolve('4155550105', null);
        System.assertEquals('OUT_OF_SERVICE', r.reason);
        System.assertEquals(false, r.resolved);
    }

    @IsTest
    static void unknownNumber() {
        System.assertEquals('UNKNOWN', StationResolver.resolve('4155559999', null).reason);
    }

    @IsTest
    static void scoringThreshold() {
        System.assertEquals(35, ScoringService.score('FIRE', false, false));
        System.assertEquals(60, ScoringService.score('FIRE', true, false));
        System.assertEquals(0, ScoringService.score('OTHER', false, false));
    }
}