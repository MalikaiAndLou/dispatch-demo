---
date: 2026-11-08
phase: build
type: correction
---

## What happened

Case lookup field created as `Station_ID__c` rather than `Station__c` — label "Station ID" drove the API name.

## Decision

Accept it. Flow references use `Station_ID__c`.

## Why

Renaming costs a round trip and changes nothing functionally.

## Follow-up

Use `Station__c` in the production build to match Appendix A/B.
