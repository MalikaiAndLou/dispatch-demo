---
date: 2026-11-12
phase: review
type: correction
---

## What happened

A review pass over the two-day demo, the night before the technical interview.

Scope was set on 11-08 with the interview assumed to be any day between Wednesday and Friday. It was confirmed for Friday on the morning of 11-11. The build was therefore optimised for the demo path and bulkification was knowingly deferred. This entry is the cost of that deferral, written after the fact.

The trigger for the pass was a read of the six Apex classes in order. Three defects fell out immediately.

## The findings

**Query cost.** VoiceCallIntake issued four SOQL per record: one resolver scan, two from CaseRouter via the after-insert trigger, one re-query for CaseNumber. At a 100-query ceiling that is a wall at roughly 25 records in one transaction. A Flow invocable can be handed 2000.

Proven, not assumed. A 200-record test failed with:

    System.LimitException: Too many SOQL queries: 101
    Class.CaseRouter.route: line 16
    Trigger.CaseRouterTrigger: line 2

The failure landed inside the router, not the intake, because the router was the heavier of the two.

**Empty normalisation matched junk.** digitsOnly returns an empty string for input with no digits. A DNIS of + normalised to empty, and every Station whose DNIS was also non-numeric normalised to empty. Empty equalled empty. A bare + resolved to the first junk station in scan order instead of failing.

**LIMIT 1 without ORDER BY hid duplicates.** Two Stations on one DNIS resolved to an arbitrary winner, varying between runs, with no ambiguity signal. A wrong building is worse than a refusal.

**Doc contradicted code.** build-report.md claimed priority comes from the row, never from the score. VoiceCallIntake sets P0 from the score before insert. The router only overwrites when the row has a priority, so a score-derived P0 survives on rows where Priority is null. The sentence was too absolute.

## What was changed, and why

StationResolver - resolveAll now takes a list, does one DTMF query and one DNIS scan for the whole batch, buckets matches, and returns a Result per input. Adds AMBIGUOUS_DTMF and AMBIGUOUS_DNIS. The single-record resolve(String, String) is kept as a one-element wrapper so the Aura entry point and ResolveStationAction keep working.

VoiceCallIntake, SilentAlarmIntake, AgentEmergencyIntake - rebuilt to build a request list, resolve once, insert once with Database.insert(..., false), and emit exactly one Response per Request in order. success was added so a Flow can branch without parsing message strings. Message strings were left unchanged so no Flow binding broke.

CaseRouter - gains a Trigger.isBefore branch that mutates Trigger.new with no DML, so the class is no longer silently after-insert-only. Null and blank Zone_Code now fall to the DEFAULT map instead of a dead intent|null key. Queue Ids are validated for length and by Id.valueOf before assignment. Priority is checked against the picklist describe. Metadata is cached per transaction. The update is Database.update(..., false) so one bad record no longer sinks the batch. Routing_Decision gains an exact or fallback suffix.

CaseScreenPopController - one query with relationship traversal instead of two, WITH USER_MODE, AuraHandledException with setMessage, and the station block degrades instead of throwing when the Station is invisible or deleted.

ResolveStationAction - calls resolveAll once for the batch.

ScoreEmergencyAction - null guards, per-record isolation, and a ScoreOut DTO with scored, band and reason instead of a bare Integer.

## Things learned the hard way

@TestSetup and @IsTest(SeeAllData=true) cannot coexist on one class. Test setup is only supported in default isolation mode.

Database.insert(records, false) does not populate auto-number fields in memory. CaseNumber had to be queried back in one WHERE Id IN pass after the DML.

Set<Id> is not a legal @AuraEnabled parameter. List<Id> is.

A 17-character queue Id recurrence. During the metadata revert a truncated Id was pasted. It is 18 characters and the missing character was an h. This is the same failure as 0011. isValidQueue rejects a 17-character value and leaves OwnerId untouched, so the new code fails silently rather than throwing. Silent is better than a crash and still not good.

## What it costs

Four days of demo scope were not revisited: Omni-Channel, presence, telephony, 911 egress. Section 9 of the build report stands.

The DNIS scan is still a full table read with a 5000-row cap. A normalised External Id field is the real fix and is not implemented.

SeeAllData is still on in every pre-existing test class except DispatchServicesReviewTest. Removing it needs fixtures for the required Building and Zone hierarchy on Station. Deferred deliberately. It is the next test task.

## Follow-up

1. DNIS_Normalized__c and DTMF_Normalized__c as Text, External Id, unique. Removes the scan and makes duplicates a constraint error rather than an Apex check.
2. Move SeeAllData off the remaining test classes with @TestSetup fixtures.
3. Move band thresholds out of VoiceCallIntake and into ScoringService, and validate P0 against the picklist at deploy time.
4. Add a bulk test to each intake class, not only VoiceCallIntake.

## How to read this diff

demo-freeze marks the commit before this pass.

    git diff demo-freeze..HEAD --stat

All five demo paths were re-run by hand after the last commit: silent alarm, voice with DNIS, agent free text, live metadata edit, escalation timer. All passed.
