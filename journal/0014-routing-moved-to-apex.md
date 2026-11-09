---
date: 2026-11-09
phase: build
type: reversal
---

## What happened

Abandoned Route_Case_To_Queue for an after-insert trigger. The flow could route a
Case in debug but faulted on every real insert, wrote ROUTING FAULT, and its canvas
stopped matching the live version.

## Decision

Routing moved to CaseRouter / CaseRouterTrigger. Flow deactivated and left in place.

## Why

Four flow defects stacked up in one session: start-condition Is Null returning false
against a null DateTime, the same failure inside a decision element, $Record two-hop
traversal (Station ID > Campus Zone) resolving empty on insert, and fault elements
that were invisible in the builder yet still firing. Each fix cost a round trip.

Apex has none of those failure modes. It also throws real exceptions, and the rule is
now covered by a passing test class, which is a stronger artifact to show than a canvas.

## Bugs hit in the Apex version

- Trigger.new is read-only in an after trigger; the first version mutated it and threw
  FinalException. Rewritten to build its own update list.
- Tests could not see Station records without SeeAllData=true.

## Verification

Case 00001047: FIRE / MB-03, Campus Emergency Dispatch, P1, timestamped. CaseRouterTest 2/2.

## What it costs

- The flow represents a day of work and is now dead code. It stays as a reference.
- Metadata still stores queue IDs rather than names, so the table breaks on refresh.
- No trigger guard against re-routing on update, but the trigger is after-insert only,
  so edits cannot re-route.

## Follow-up

Silent-trigger path, then the screen pop. Queue-name refactor before the interview.
