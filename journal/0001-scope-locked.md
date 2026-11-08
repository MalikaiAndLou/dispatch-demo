---
date: 2026-11-08
phase: build
type: decision
---

## What happened

Scope set before the first click.

## Decision

- Telephony simulated with a Screen Flow. No Connect, no Lex.
- Intent is a picklist. Dev org has no Agentforce licensing.
- Two paths: voice call and silent trigger.
- Cut: Incident clustering, Fanout_Leg, IoT, camera, automated fan-out.
- Kept: resolver, scoring, metadata routing, screen pop, out-of-service station, live metadata edit.

## Why

Every cut sits downstream of the routing decision. The demo proves the destination is a table.

## What it costs

Intent-as-picklist is the biggest honest gap. Closing slide, not footnote.

## Follow-up

If debugging overruns, drop the screen pop and keep the routing-table moment.
