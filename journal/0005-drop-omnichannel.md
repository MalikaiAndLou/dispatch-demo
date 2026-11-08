---
date: 2026-11-08
phase: build
type: reversal
---

## What happened

Service Cloud User flag set on the admin user; Service Channels still absent from Setup. Developer Edition is not provisioned for Omni-Channel, and the licence flag alone doesn't create it.

## Decision

Drop Omni-Channel from the demo. Cases route by setting `OwnerId` to the queue ID. Queue IDs live in Custom Metadata rather than being resolved by developer name.

## Why

Fifteen minutes already lost to org provisioning. Everything the demo is for — metadata-driven destination, queue assignment, live reroute, screen pop — survives intact.

## What it costs

Loses Route Work, capacity mechanics, and the word "Omni-Channel" in the UI. Production design is unaffected; the Flow gains a one-line swap when it moves to a real org.

## Follow-up

If a Service Cloud org is ever available, restore Route Work in Appendix B and drop the queue-ID metadata lookup.
