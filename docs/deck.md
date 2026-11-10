# From PoC to go-live

### Additions to the campus emergency PoC

Speaker notes: frame this in the first sentence. "I haven't seen your PoC. This isn't a
replacement — it's the parts between where a PoC usually stops and where a campus can
actually run it. I built working versions of the hard ones so you can judge the skill,
not the slide."

---

## What a campus emergency line has to do

- Answer a caller who may be panicking and may not know where they are
- Take an alarm from a blue-light station with nobody on the line
- Decide, in seconds, which team goes and how urgent it is
- Put the location, the camera and the decision in front of a dispatcher
- Escalate when nobody picks it up
- Bridge to 911 when campus response isn't enough

Speaker notes: read the list, don't embellish. The point is that each line is a
requirement, and each has a build consequence.

---

## Where a PoC stops

| PoC | Go-live |
|---|---|
| Intent as a picklist | Classified from speech |
| Hard-coded queue names | Routing table, editable without deploy |
| Case created, owner set | Owner set, dispatcher alerted, unclaimed work escalated |
| One happy path | Fallback, fault paths, empty states |
| Demo data | Permission model, agent user, audit |

Speaker notes: this is the slide that earns the interview. Be specific about which
column their PoC is probably in, and say you'd want to see it before committing.

---

## What this demo proves

Working, in a Developer Edition org, in two days:

- Metadata-driven routing with per-intent fallback
- Three entry points: simulated voice, silent alarm, and an Agentforce agent
- Dispatcher screen pop with station, camera and the rule that fired
- Unclaimed P0 escalation on a timer
- 10 test methods, all passing

Speaker notes: two days is the number that matters. It's the argument that adding to
their PoC is weeks, not quarters.


## Architecture

```
flowchart LR
    V[Voice call] --> R
    S[Silent alarm] --> R
    A[Agent text] --> R
    R[CaseRouter] --> M[(Routing_Map__mdt)]
    M --> Q[Queue + priority]
    M -.->|DEFAULT per intent| Q
    Q --> P[Screen pop]
```
Speaker notes: three doors, one router. The router is the only place that decides
anything, so behaviour is auditable in one place.

---

## Routing is data

- Eight rows of intent + zone → queue + priority
- Exact match, then DEFAULT per intent, then NO ROUTE
- Changing a destination is a metadata edit, no deployment
- Demoed live: ASSAULT/MB-03 moved to another queue, Case rerouted

Speaker notes: this is the slide a facilities stakeholder cares about most. They can
remap without a release.

---

## The agent

- Agentforce Service Agent, one subagent, one action
- Classifies free text into five intents, collects location and injury
- Creates and routes the Case, reads the number back
- Messaging today; the same topic takes ASR output when Connect lands

Speaker notes: be explicit that it's messaging, not voice. The classifier is the piece
that makes the voice leg possible later.

---

## The screen pop

- Station, class, building, zone, health badge
- Camera tile, blacked out with NO SIGNAL when the station is down
- The rule that fired, priority, privacy flags
- Empty state when no station resolved

Speaker notes: a dead camera must be visible at dispatch, not discovered later. The
badge is the feature.

---

## Escalation and 911

- P0 unclaimed after two minutes → re-owned to a named dispatcher, decision stamped
- Campus dispatch is the tenant; 911 is a dispatcher bridge, not an auto-dial
- 911 needs a human on the line, a callback ANI and a dispatchable address

Speaker notes: campus police reach a campus building faster than a PSAP. But
campus-first must never become campus-only.

---

## Evidence

- `CaseRouterTest`, `VoiceCallIntakeTest`, `SilentAlarmIntakeTest`,
  `AgentEmergencyIntakeTest`, `DispatchServicesTest` — 10/10
- Journal, in order, including what broke
- Build report with the component inventory and the gap list

Speaker notes: offer the repo. Point at the journal specifically — it shows how you
work when it goes wrong, which is the actual hire.

---

## What broke, and what it taught

- 17-character queue IDs hid behind missing fault connectors: two hours
- `Is Null` returned false against a null DateTime: replaced with ISBLANK
- An Apex action that never invoked: replaced with a flow action
- A queue view that couldn't show new Cases: the "no case" reports were the list's fault

Speaker notes: don't apologise. Each one names a lesson: fault connectors on every DML
element, never hand-type an ID, verify the instrument before trusting it.

---

## Rollout

1. Connect and PSTN, one building
2. Routing table to production, zone derived from building
3. Screen pop to the dispatch desk, with empty and error states
4. Escalation with a real on-call rota
5. 911 bridge, E911 address data
6. Agent on voice, after the classifier is tuned on real calls

Speaker notes: one building first. The table and the pop are the value; telephony is
procurement.

---

## What I'd need from you

- Access to the existing PoC
- The queue and skill model dispatch actually uses
- Whether 911 bridging is in scope or a later phase
- A named on-call rota for escalation

Speaker notes: these are the questions that show you've done this before. Ask them.

---

## Close

Working proof of the hard parts, in two days, with the gap list written down.

Speaker notes: stop talking. Let them ask.