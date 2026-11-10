---
date: 2026-11-09
phase: build
type: surprise
---

## What happened

Built the Agentforce front-line agent: Emergency Dispatch, Service Agent, one
subagent, one action, GPT-4.1 mini. Verified end to end — Case 00001062 created as

@'
---
date: 2026-11-09
phase: build
type: surprise
---

## What happened

Built the Agentforce front-line agent: Emergency Dispatch, Service Agent, one
subagent, one action, GPT-4.1 mini. Verified end to end — Case 00001062 created as
FIRE from the utterance "smoke coming from the stairwell in Byers Hall", routed to
Campus Emergency Dispatch, FIRE / DEFAULT, case number returned to the caller.

## What broke first

The Apex action (apex://AgentEmergencyIntake) never invoked. Symptoms in order:
"I don't have a case-creation function", then "there was a system error", with no
Debug Log entry and no Apex executed. Rebuilding the action by hand did not help.

## What actually fixed it

Two things, in this order:
1. Agent user permissions — the agent ran as a user with no Case create, no Station
   read and no Apex class access. All three were granted via permission set.
2. The action was switched from Apex to an autolaunched Flow (Agent_Create_Case)
   that inserts the Case. The flow action bound first time.

## Diagnosis notes

The subagent inherited the router's DefaultEinsteinHyperClassifier, which only
supports transitions. Setting the subagent to GPT-4.1 mini was required before any
action could fire.

Debug Logs never captured the Apex, which is the tell: the platform failed before
reaching the class.

## What it costs

- Roughly three hours on an action binding that never worked.
- The agent does not call the Apex path at all now, so AgentEmergencyIntake is dead
  code alongside VoiceCallIntake. Both stay for reference.
- Priority is P1 from the metadata DEFAULT row, not P0. Correct, but the agent never
  derives severity.
- An Optimizer-driven rebuild produced a script with duplicate action lines and broke
  on Ctrl+Z. Hand-editing was more reliable.

## Follow-up

Confirm voice and silent flows still work. Reconcile the deck.
