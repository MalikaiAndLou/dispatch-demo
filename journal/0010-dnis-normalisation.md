---
date: 2026-11-08
phase: build
type: correction
---

## What happened

`DNIS__c` is Phone, so import normalised `4155550103` to `(415) 555-0103` and exact SOQL matching failed two tests.

## Decision

Cannot convert the type while Apex references it, so normalise in Apex instead: strip non-digits and compare. Field stays Phone.

## Why

Matching must be on raw digits; the schema change can wait.

## What it costs

A loop over all stations instead of an indexed query. Fine at twelve records, wrong at ten thousand.

## Follow-up

Production carries a normalised Text field. `DTMF_Code__c` is already Text for this reason.
