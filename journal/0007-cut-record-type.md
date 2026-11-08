---
date: 2026-11-08
phase: build
type: cut
---

## What happened

Support Processes is absent from the Case object in this Developer Edition org, so no custom record type can be created.

## Decision

Use the Master record type. All six Case fields go on Master and on the standard Case layout.

## Why

Nothing in the demo depends on the record type. Routing, the pop and the metadata table are indifferent. Restoring it later is a wizard run, not a rebuild.

## What it costs

Cases look like ordinary Cases in list views. No visual distinction between duress and service requests.

## Bring it back if

The org changes, or before any demo where the Case list is shown.
