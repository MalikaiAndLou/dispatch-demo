---
date: 2026-11-09
phase: build
type: surprise
---

## What happened

Silent alarm path built as its own entry point: Silent_Trigger_Intake screen flow
calling SilentAlarmIntake.create, which resolves the station by name, creates the
Case as ASSAULT with Anonymous true and Contains PHI false, and lets the router run.

Verified with MB-BY-BL02: Owner Duress, Priority P0, decision ASSAULT / MB-03,
Anonymous ticked, PHI unticked.

Station MB-BY-BL02 set to Status "Out of Service", Health Status RED, rerun. Case
still created and still routed to Duress at P0. A dead camera does not suppress the
alarm.

## Decision

Two entry points, one routing engine. Voice intake and silent intake are separate
flows because a caller and an alarm share nothing but the destination.

## Why

The choice-radio branch inside the single intake flow failed four times: chip
comparison, blank choice Value, literal text, and finally the component itself
storing "Voice" rather than the label. Splitting the paths removed the decision
entirely, and the pair now reads as what it models: an IVR leg and an alarm leg.

## What it costs

- Two flows to maintain instead of one.
- The station carries a Zone Code duplicating its Building's zone. They disagreed
  during the build (MB-07 vs MB-03) and had to be reconciled by hand. Production
  should derive zone from Building.
- Case timeline shows three "Case updated" entries on a voice run. Unexplained;
  field history tracking is off so it cannot be broken out. Cosmetic, unfixed.

## Open defect

The confirmation screen says "Created" even when the station is Out of Service. The
Apex returns the correct message ("Station out of service") but the screen is not
surfacing it. The message is the whole point of the RED badge, so this must be fixed
before the demo. Resume here.

## Follow-up

Fix the confirmation message binding. Then the screen pop, where the RED badge
belongs as something a dispatcher sees rather than a string.
