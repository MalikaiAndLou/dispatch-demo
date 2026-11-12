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
        if (reqs == null || reqs.isEmpty()) return outs;

        List<StationResolver.Input> inputs = new List<StationResolver.Input>();
        for (ResolveIn req : reqs) {
            inputs.add(new StationResolver.Input(req == null ? null : req.dnis, req == null ? null : req.dtmf));
        }
        List<StationResolver.Result> results = StationResolver.resolveAll(inputs);

        for (Integer i = 0; i < reqs.size(); i++) {
            StationResolver.Result r = results[i];
            ResolveOut o = new ResolveOut();
            o.resolved    = r != null && r.resolved == true;
            o.reason      = r == null ? 'RESOLVER_NULL' : r.reason;
            o.stationCode = r == null ? null : r.stationCode;
            o.stationClass = r == null ? null : r.stationClass;
            o.zoneCode    = r == null ? null : r.zoneCode;
            o.buildingName = r == null ? null : r.buildingName;
            o.stationId   = r == null ? null : r.stationId;
            o.matchedBy   = r == null ? null : r.matchedBy;
            outs.add(o);
        }
        return outs;
    }
}