---
date: 2026-11-09
phase: build
type: decision
---

## What happened

Asked who gets notified when a P0 lands in a queue, and whether a duress press
should go straight to 911. Neither had been designed.

## Decision

1. Campus dispatch is the tenant of the system. They own the queues, watch them, and
   decide when to bridge to 911. The system alerts nobody by ringing a phone, because
   the dispatcher is already sitting in front of it.

2. A duress or blue-light press routes internally to the Duress queue at P0. It does
   NOT auto-dial 911.

3. Dispatcher bridges to 911 by live transfer, not notification. 911 cannot interrogate
   a machine, so a human stays on the line.

4. A `Requires_911__c` style flag belongs on the routing metadata row so 911-eligible
   emergencies are highlighted rather than reasoned about under pressure.

5. Because the dispatcher may be on another call, an unclaimed P0 escalates on a timer.

## Why

Campus police reach a campus building faster than a municipal PSAP and hold the keys,
the cameras and the station map. Routing internally first is faster for the caller and
better informed for the responder.

But campus-first must never become campus-only. The 911 flag makes the exception
visible without adding a step to the common path.

## What it costs

- Two-hop response: internal dispatch, then possibly 911. Slower than a direct 911
  dial for the genuinely life-threatening case, mitigated by the flag.
- Requires a carrier with 911 egress and E911 address data to bridge properly.
  Building and Nearest_Entrance are the start of that, not the whole of it.
- Escalation timer needs a named fallback owner, which is a staffing commitment, not
  just a field.

## Follow-up

Build Escalate_Unpicked_P0 as a scheduled path, 5 minutes after Routed_Timestamp, on
P0 Cases still New. Re-own to the dispatcher and append ESCALATED to the decision.
