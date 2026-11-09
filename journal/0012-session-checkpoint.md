---
date: 2026-11-09
phase: build
type: risk
---

## What happened

Routing now works end to end for the first time. Case 00001037 was created by
Simulated_Call_Intake with FIRE at station MB-GH-VS01 and routed itself to the
Campus Emergency Dispatch queue with decision FIRE / MB-03, Priority P1, and a
Routed Timestamp. 0011 records the root cause.

## Where the build actually stands

Working and verified:

- Objects Campus_Zone__c, Building__c, Station__c, plus nine Station fields
- Case fields: Emergency_Type__c, Station_ID__c, Score__c, Routing_Decision__c,
  Routed_Timestamp__c, Contains_PHI__c, Anonymous__c
- Routing_Map__mdt with eight rows, all IDs corrected 2026-11-09
- StationResolver and ScoringService, DispatchServicesTest 4/4
- ResolveStationAction and ScoreEmergencyAction invocable wrappers
- Simulated_Call_Intake Screen Flow, voice and silent branches
- Route_Case_To_Queue v9, active, Condition Requirements = None

Not working or not started:

- Start condition guard is OFF. Flow re-routes on every save and recursed twice on
  00001037. Any dispatcher edit re-routes the Case.
- No fault connectors from updFound or updDefault into updFault. This is what hid
  the ID defect for two hours.
- Silent-trigger path unverified; MB-BY-BL02 has never been exercised.
- Screen pop not built: map, floorplan, camera tile, health badge, decision panel.
- Live metadata edit not rehearsed.
- No validation rules, no duplicate rules, no Case assignment rules.

## Authoritative values, so morning does not re-query

Queues (Group, Type=Queue, 18 char):
- Campus Emergency Dispatch  00GjV00000354xJUAQ
- Duress                     00GjV00000354vhUAA
- Facilities Elevator OnCall 00GjV00000354yvUAA

Demo DNIS: 4155550103 -> MB-GH-VS01 (zone MB-03)
Silent-trigger station: MB-BY-BL02 (zone MB-07)

## Decision or observation

Stop for the night rather than push the guard while tired. The guard and the fault
connectors are both five-minute jobs and both are prerequisites for anything else.
Sequencing them first tomorrow.

## Why

Condition Requirements = None is fine for proving the table works, and it is how we
got 00001037. But a Case that re-routes on every save is a bad demo: the audience
watches a dispatcher add a note and the Case jumps queues. The guard has to go back
on before the screen pop, because the screen pop involves writing to the Case.

The fault connectors matter more than they look. Three separate diagnostics pointed
at the start condition, the decision element and the field rows. None were at fault.
A loud error would have ended it in ten minutes.

## What it costs

- Flow currently unsafe to save against during demo prep.
- Every additional flow change compounds on an unguarded trigger.
- Interview date is fixed; two of the eight build steps are now blocking.
- Trust in the debug trace is lower than it should be, because success was reported
  while DML failed.

## Follow-up

Tomorrow, in order:

1. Start condition back on: Routed Timestamp, Is Null, Value empty. Verify with a
   fresh intake, not a debug run. If it fails, screenshot the whole start panel
   before changing anything.
2. Red fault connector from updFound and from updDefault into updFault.
3. Silent-trigger path end to end, MB-BY-BL02, confirm Out of Service / RED.
4. Screen pop.
5. Rehearse the live metadata edit: ASSAULT / MB-03 to Duress, re-run, confirm
   reroute with no deploy.
6. Refactor Queue_Id__c from ID to queue DeveloperName, resolved at runtime, so the
   table survives sandbox refresh.
7. Deactivate nothing further without journaling it.
