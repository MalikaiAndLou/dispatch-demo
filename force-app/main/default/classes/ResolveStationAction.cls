public with sharing class ResolveStationAction {

    public class ResolveIn {
        @InvocableVariable public String dnis;
        @InvocableVariable public String dtmf;
    }

    public class ResolveOut {
        @InvocableVariable public Boolean resolved;
        @InvocableVariable public String reason;
        @InvocableVariable public String stationCode;
        @InvocableVariable public String stationClass;
        @InvocableVariable public String zoneCode;
        @InvocableVariable public String buildingName;
        @InvocableVariable public Id stationId;
        @InvocableVariable public String matchedBy;
    }

    @InvocableMethod(label='Resolve Station')
    public static List<ResolveOut> run(List<ResolveIn> reqs) {
        List<ResolveOut> outs = new List<ResolveOut>();
        for (ResolveIn req : reqs) {
            StationResolver.Result r = StationResolver.resolve(req.dnis, req.dtmf);
            ResolveOut o = new ResolveOut();
            o.resolved = r.resolved;
            o.reason = r.reason;
            o.stationCode = r.stationCode;
            o.stationClass = r.stationClass;
            o.zoneCode = r.zoneCode;
            o.buildingName = r.buildingName;
            o.stationId = r.stationId;
            o.matchedBy = r.matchedBy;
            outs.add(o);
        }
        return outs;
    }
}