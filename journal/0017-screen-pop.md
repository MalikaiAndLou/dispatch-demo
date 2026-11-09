---
date: 2026-11-09
phase: build
type: decision
---

## What happened

Built the dispatcher screen pop as an LWC on the Case record page with a read-only
Apex controller. Shows station code and class, building, zone, camera tile, health
badge, nearest entrance, and the routing decision with priority and privacy flags.

## Decision

LWC on the record page, not an Omni-Channel console tab. This org has no Omni-Channel
so there is nothing to dock into. A record-page component is honest about that and
the deck already says Connect is simulated.

## Why

The routing decision is worthless if a dispatcher has to open four records to act on
it. The pop collapses station, asset health and the rule that fired into one panel.
The RED badge is the point: a dead camera is visible at the moment of dispatch rather
than discovered later.

## What it costs

- Component assumes Station_ID__c is populated. Silent alarms set it; voice calls
  without a known DNIS do not, so the panel renders empty for those. Needs an empty
  state.
- Score pill is hidden when null rather than showing zero, so silent alarms show no
  score at all. Acceptable, but it means the panel reads differently by path.
- Camera tile is a black box with an ID, not a real feed. Nothing is streaming.

## Follow-up

Empty state for no-station Cases. Then the live metadata edit rehearsal and deck
reconciliation.
