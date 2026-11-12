# Campus Emergency Dispatch — build report

## What this is

A working proof of concept, built in a Developer Edition org, of an emergency triage
front door for a university campus. Two entry points feed one routing engine and one
dispatcher screen.

Built in roughly two days. Every component is real and runs; every gap against a
production system is listed in section 9.

## What this is not

Not a call centre. There is no telephony, no PSTN, no Omni-Channel and no presence.
The voice leg is a Screen Flow that simulates an inbound call. The agent is
demonstrated over messaging, not voice. Section 9 is explicit about each gap.

## Architecture

Two entry points, one router:

- **Voice intake** — caller DNIS resolves to a station, intent is captured, a score
  drives severity, a Case is created.
- **Silent intake** — an alarm carries a station code only. Case created as ASSAULT,
  Anonymous true, Contains PHI false.
- **Agent intake** — free text classified into one of five intents, then the same Case
  creation path.

All three land on `CaseRouterTrigger`, which reads `Routing_Map__mdt` and assigns the
Case to a queue with a priority. The dispatcher sees the Case with a screen pop.

Routing is data, not code. A queue change is a metadata row edit with no deployment.

## Component inventory

**Objects and fields**
- `Campus_Zone__c` — zone code, high-crime flag, DTMF flag, active flag
- `Building__c` — building code, floors, zone lookup
- `Station__c` — station class S1–S6, DNIS, DTMF code, status, health status, camera
  ID, nearest entrance, zone code, building lookup
- Case fields — Emergency Type, Station ID, Score, Routing Decision, Routed Timestamp,
  Contains PHI, Anonymous

**Routing**
- `Routing_Map__mdt` — eight rows of intent + zone to queue + priority, with a DEFAULT
  zone fallback per intent

**Apex**
- `StationResolver` — DNIS or DTMF to station, digit-normalised, flags out of service
- `ScoringService` — intent, injury and asset weights against a threshold
- `CaseRouter` + `CaseRouterTrigger` — after-insert routing, reads the metadata table
- `VoiceCallIntake`, `SilentAlarmIntake` — invocable case creation per entry point
- `CaseScreenPopController` — read-only panel data
- `AgentEmergencyIntake` — invocable for the agent (superseded by a flow, see 8)
- Tests: `DispatchServicesTest`, `CaseRouterTest`, `VoiceCallIntakeTest`,
  `SilentAlarmIntakeTest`, `AgentEmergencyIntakeTest` — 10 methods, all passing

**Flows**
- `Simulated_Call_Intake` (label Voice Call Intake) — voice front door
- `Silent_Trigger_Intake` — silent front door
- `Agent_Create_Case` — autolaunched, called by the agent action
- `Escalate_Unpicked_P0` — scheduled path, re-owns an unclaimed P0 after 2 minutes
- `Route_Case_To_Queue` — the original routing flow, now inactive

**Agent**
- `Emergency Dispatch` — Service Agent, one subagent, GPT-4.1 mini, one flow action

**UI**
- `caseScreenPop` — LWC on the Case record page: station, badge, camera tile, decision

**Security**
- `Dispatch Agent Access` permission set: Case create/edit, Station read, Apex class
  access, assigned to the agent user

## Front end

The screen pop is a Lightning Web Component on the Case record page, backed by an
`@AuraEnabled(cacheable=true)` controller. It wires to the record id, guards against an
undefined payload on first render, and renders an explicit empty state when no station
resolved. Badge colour, camera blackout and score pill are conditional on data, so a
voice call with no DNIS and a silent alarm on a dead camera look different without any
branching in the markup.

The whole bundle was authored by hand in a browser-only org with no SFDX CLI — no local
project, no deploy tooling, four files typed into the builder.

## How routing decides

`CaseRouter` takes the Case intent and the station's zone, looks for an exact
intent+zone row, falls back to the intent's DEFAULT row, and only then gives up with
NO ROUTE. Priority comes from the row; a score-derived P0 survives only where the row leaves priority blank. Score is recorded but does
not override the table.

## Tests

Ten methods across five classes, all passing. They cover DNIS normalisation, scoring
weights, exact and fallback routing, both intake paths and the silent path landing P0
on Duress.

## Decisions worth reading

- Omni-Channel was dropped entirely: Service Channels never appeared in this org. Queue
  assignment is `OwnerId`. Journal 0005.
- Routing moved from Flow to Apex after four separate flow defects. Journal 0014.
- A 17-character queue ID defect hid behind missing fault connectors for two hours.
  Journal 0011.
- `Is Null` returned false against a null DateTime, in both a start condition and a
  decision. Replaced with an ISBLANK formula. Journal 0013.
- The agent's Apex action never invoked. Replaced with a Flow action, which bound first
  time. Journal 0018.
- Campus dispatch is the tenant; 911 is a dispatcher bridge, not an auto-dial. Journal
  0019.

## What a real system adds

- Omni-Channel routing on skills and presence, not `OwnerId`
- Audible alert and screen pop on arrival, from the softphone vendor
- Accept/decline with automatic reassignment
- Supervisor visibility, service-level milestones, wallboard, silent monitor
- Amazon Connect, PSTN, 911 egress, E911 dispatchable address
- Queue-level reporting: time to answer, abandon rate

## What I would do next

1. Store queue names, not IDs, in the metadata so the table survives a refresh.
2. Derive station zone from building rather than duplicating it.
3. Replace the intent picklist with the agent on the voice leg too.
4. A `Requires_911__c` flag on metadata rows so 911-eligible work is highlighted.
5. Empty state and error handling on the panel for Cases with no station.
