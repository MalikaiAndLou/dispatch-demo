---
date: 2026-11-09
phase: build
type: risk
---

## What happened

Escalation timer fired but silently — the Case re-owned with no signal unless someone
happened to be looking at the Duress queue. Raised whether a real system alarms
audibly, and asked for the full list of what Omni-Channel and a real call centre would
change.

## Decision

Capture the gap list explicitly as an interview artifact. Do not build substitutes for
items that need infrastructure this org does not have.

## The gap list

- Routing: Omni-Channel with skills and presence, not OwnerId set to a queue.
- Alerting: audible alert and screen pop on arrival, configured per queue. The sound
  comes from the softphone or CTI vendor, not from Omni-Channel itself.
- Acceptance: accept/decline with a timer and automatic reassign on decline.
- Escalation: supervisor visibility and service-level milestones, not a flow timer.
- Voice: Amazon Connect, PSTN, 911 egress, E911 dispatchable address.
- Supervision: wallboard, silent monitor, barge-in.
- Reporting: queue-level service levels, abandon rate, time to answer.

## Why

The current build sets OwnerId to a queue. That is a filing cabinet. Nothing rings,
nothing escalates to a supervisor, nothing measures whether anyone answered in time.
Naming that plainly is stronger than half-building substitutes and pretending.

The timer built here is a backstop for "nobody picked it up", not a primary alert.
A P0 should alert on arrival; the timer only covers the case where it did not.

## What it costs

- The demo understates how loud a real dispatch desk is. Mitigated by the gap slide.
- Two behaviours are genuinely misleading without the caveat: no audible alert, and
  the 5-minute escalation delay. Five minutes is a long time for someone in a stairwell.
- Offset should be severity-dependent in the real system: P0 faster than P1.

## Follow-up

Gap slide in the deck. Change the timer to 2 minutes for P0 if time allows, and say on
camera that it is a backstop.
