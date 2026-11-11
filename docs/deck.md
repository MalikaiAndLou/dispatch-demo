---
marp: true
theme: default
paginate: true
---

<!-- _class: lead -->
<!-- _backgroundImage: url('img/hero.jpg') -->
<!-- _backgroundSize: cover -->
<!-- _backgroundOpacity: 0.6 -->
<style>
section {
  font-family: "Segoe UI", system-ui, sans-serif;
  font-size: 26px;
  color: #1a1a1a;
  padding: 60px 70px;
}
h1 { color: #16325c; font-size: 52px; line-height: 1.05; margin-bottom: 12px; }
h2 { color: #16325c; font-size: 38px; border-bottom: 3px solid #c23934; padding-bottom: 10px; margin-bottom: 28px; }
h3 { color: #54698d; font-weight: 500; font-size: 24px; margin-top: 0; }
ul { list-style: none; padding-left: 0; }
li { margin-bottom: 14px; padding-left: 26px; position: relative; }
li::before { content: ""; position: absolute; left: 0; top: 12px; width: 10px; height: 10px; background: #c23934; }
table { font-size: 21px; border-collapse: collapse; width: 100%; }
th { background: #16325c; color: #fff; text-align: left; padding: 8px 12px; }
td { padding: 8px 12px; border-bottom: 1px solid #d8dde6; }
td:first-child { color: #54698d; }
section.lead { background: #0d1f38; color: #fff; justify-content: center; text-align: left; padding-left: 90px; }
section.lead h1 { color: #fff; font-size: 60px; margin-left: -4px; }
section.lead h3 { color: #9db9d6; font-size: 24px; }
section.lead p { font-size: 19px; }
section.lead p:last-of-type { font-size: 12px; opacity: .45; margin-top: 26px; }

section.lead { position: relative; }
section.lead::after {
  content: ""; position: absolute; inset: 0; z-index: 0;
  background: linear-gradient(90deg,
  rgba(13,31,56,.97) 0%,
  rgba(13,31,56,.88) 40%,
  rgba(13,31,56,.55) 100%);
}
section.lead h1, section.lead h3, section.lead p { position: relative; z-index: 1; }
</style>


# From PoC to go-live

### Additions to the campus emergency PoC

**Daniel Cadwell** · Salesforce architect-developer

<span style="font-size:13px; opacity:.55">Photo: geraldlangphotography / Pixabay</span>

<!-- ## Slide 1 — Title
Hi, I'm Daniel Cadwell, a Salesforce architect and developer. This is a fifteen-minute walkthrough of an emergency dispatch
build on Salesforce — specifically the parts between a proof of concept and a campus
actually, running one.

The problem underneath it is triage: deciding, in seconds, which team goes and how fast,
and being able to prove afterwards why.

Smoke in a stairwell on a campus. In thirty seconds somebody has to work out where it is,
what it is, who owns it, and how fast it moves. Most of that is routing, and routing is
where these builds fall apart. So I built the routing.
 -->

---

## What a campus emergency line has to do

- Answer a caller who may be panicking, and may not know where they are
- Take an alarm from a blue-light station with nobody on the line
- Decide in seconds which team goes, and how urgent it is
- Put the location, the camera and the decision in front of a dispatcher
- Escalate when nobody picks it up
- Bridge to 911 when campus response isn't enough

<!--
## Slide 2 — What a campus emergency line has to do
"Six things, none optional. A panicking caller who doesn't know what building they're in. An
alarm with nobody on the line. A decision in seconds. Location, camera and decision in front
of a dispatcher. Escalation when nobody picks it up. A bridge to 911 when campus isn't
enough.
 
Every line is a requirement with a build consequence. That's the point of the list."

-->

---

## Where a PoC stops

| PoC | Go-live |
|:--|:--|
| Intent as a picklist | Classified from speech |
| Hard-coded queue names | Routing table, editable without deploy |
| Case created, owner set | Owner set, dispatcher alerted, unclaimed work escalated |
| One happy path | Fallback, fault paths, empty states |
| Demo data | Permission model, agent user, audit |

<!--
"I haven't seen yours, so I'm guessing at the column. Picklist instead of classification.
Hard-coded queue names. Owner set and nothing else — no alert, no escalation. One happy
path, no fallback. Demo data.
 
That's not a criticism, it's where every PoC stops. This is the column you'd have to fund."

-->

---

## What this demo proves

Working, in a Developer Edition org, in two days:

- Metadata-driven routing with per-intent fallback
- Three entry points: simulated voice, silent alarm, and an Agentforce agent
- Dispatcher screen pop with station, camera and the rule that fired
- Unclaimed P0 escalation on a timer
- 10 test methods, all passing

<!-- ## Slide 4 — What this demo proves
"Working, in a developer org, in two days. Metadata routing with per-intent fallback. Three
entry points. Screen pop with the rule that fired. Escalation on a timer. Ten tests passing.
 
Two days is the number that matters — it means adding to your PoC is weeks, not quarters."
 -->

---


## Architecture

![w:1080](img/arch.svg)

<!-- ## Slide 5 — Architecture
"Three doors, one router. Voice, silent, agent text — all into the same class, reading one
metadata table. The router is the only thing that decides, so behavior is auditable in one
place, and that place is a table."
 -->

---

## The silent alarm

- Fixed duress button, wall-mounted, basement lab reception
- Pressed instead of a phone: talking tells the intruder someone's been called
- The payload is a station ID and nothing else — no caller, no description, no one to ask
- Intent is inferred from the device, not captured: duress → ASSAULT → P0
- Gap: the device-to-intent map should be config, one row per device class

<!-- ## Slide 6 — The silent alarm
"Duress button, wall-mounted, basement lab reception. Someone walks in who shouldn't be
there and the tech hits it instead of calling, because talking tells the intruder she's
called someone.

All the system gets is a button press and a station ID. No caller, no description, nobody to
ask. Intent can't be captured, it comes from the device — duress means ASSAULT, and ASSAULT
means P0."
*Cut to Silent Trigger Intake, `MB-BY-BL02`, run.*
"Only the station comes through. It lands as an assault, anonymous, no patient data."
 -->

---

## The screen pop

- Station, class, building, zone, health badge
- Camera tile, blacked out with NO SIGNAL when the station is down
- The rule that fired, priority, privacy flags
- Empty state when no station resolved

![w:520](img/panel-silent.png) ![w:520](img/panel-voice.png)

<!--
## Slide 7 — The screen pop
*Cut to the Case. Panel RED, camera blacked out.*
"Station's out of service, camera's dead, so the panel is red and there's no signal. It
routes anyway. A dead camera doesn't get a vote.
 
The panel lives on the record page so the next dispatcher sees what this looked like when
it landed. Badge, camera, the rule that fired

-->

---

## The voice call

- Inbound call; DNIS resolves the building before anyone speaks
- Dispatcher captures intent — callers can't classify themselves
- Score weights intent, injury and asset class into a severity
- Station health sets the panel state; it never decides the route

<!-- ## Slide 8 — The voice call
"Other direction, different information problem. A human's on the line, so intent gets
captured instead of inferred — but callers can't classify themselves, so the dispatcher
picks it. The number resolves the building before anyone speaks."
*Cut to Voice Call Intake, `4155550103`, FIRE, injured unticked, run.*
"Fire, MB-03, P1, to Campus Emergency Dispatch."
*Open the Case.*
"Green badge, live camera, healthy station. Same router, same table."
 -->

---

## The agent

- Agentforce Service Agent, one subagent, one action
- Classifies free text into five intents, collects location and injury
- Creates and routes the Case, reads the number back
- Messaging today; the same topic takes ASR output when Connect lands
![h:330](img/agent.png)

<!-- ## Slide 9 — The agent
"Free text, from someone standing in it. The one nobody wants to staff. It classifies fire,
confirms the building, asks whether anyone's hurt, creates and routes through the same
table, then reads the number back so the person has something to hold."
*Cut to the agent tab, fresh session. Type: `smoke coming from the stairwell in Byers Hall`*
*Show the Case.*
 -->

---

## Where this goes: one front door

- The agent takes every channel — voice, SMS, chat, alarm, email
- Triage happens once, at the door, before any queue exists
- Emergency → the new dispatch path: Case, router, table, escalation
- Non-emergency → the existing process, unchanged
- One classifier, one audit trail, no parallel front doors

<!-- ## Slide 10 — Where this goes: one front door
"Everything so far is emergency intake only. The design goal is the agent as a single front
door — every channel, triaged once, at the door, before a queue exists.

Emergency goes down the path you just watched. Everything else goes to what's already
running, untouched. Your PoC keeps the non-emergency traffic it handles today, and
emergencies get a hardened path beside it. One classifier, one audit trail."
 -->

---

## Routing is data

- Eight rows of intent + zone → queue + priority
- Exact match, then the DEFAULT row per intent, then NO ROUTE
- Changing a destination is a metadata edit, no deployment
- Demoed live: ASSAULT/MB-03 moved to another queue, the Case rerouted

<!--
## Slide 11 — Routing is data
*Routing Map list view, all eight rows.*
"Eight rows. Intent, zone, priority, Queue Id. The whole decision, no if-statements — every
row is a rule a dispatcher could argue with.

That alarm's still unverified: dead camera, station out of service. Facilities has someone
in Byers tonight, so dispatch wants a body at the panel before committing an officer to what
might be nothing."
*Edit `ASSAULT / MB-03`, paste `00GjV00000354yvUAA`, pause, save.*
"One text value, saved in the browser. No deployment, no restart. Only the MB-03 row —
DEFAULT stays on Duress, so every other building's assault is untouched."
*Rerun silent flow on `MB-BY-BL02`. Open the new Case.*
"Same alarm, same station, different owner, because the row says so now."
*Restore `00GjV00000354vhUAA`, save.*

-->
---

## Escalation and 911

- P0 unclaimed after two minutes → re-owned to a named dispatcher, decision stamped
- Campus dispatch is the tenant; 911 is a dispatcher bridge, not an auto-dial
- 911 needs a human on the line, a callback ANI and a dispatchable address

<!--
## Slide 12 — Escalation and 911
"The earlier P0 hit two minutes unclaimed and re-owned to a named dispatcher with ESCALATED
stamped. A P0 in an unwatched queue didn't happen.

Campus first, because campus police reach a campus building faster than a PSAP and hold the
keys and the cameras. But campus-first can't become campus-only — 911 needs a human, a
callback number and a dispatchable address, so it stays a bridge."

-->

---

## Evidence

- `DispatchServicesTest`, `CaseRouterTest`, `VoiceCallIntakeTest`,
  `SilentAlarmIntakeTest`, `AgentEmergencyIntakeTest` — 10/10
- Journal, in order, including what broke
- Build report: component inventory and the gap list

![h:300](img/tests.png)

<!--
## Slide 13 — Evidence
What's on the slide is a run from earlier, from when the deck was built. Rather than
show you a screenshot, let's do it live.

CUT to the terminal, maximized behind the browser. Minimise the browser.

‘Ten methods. DNIS normalisation, scoring weights, exact and fallback routing, both intake
paths, silent landing P0. Start the line, then press Enter.’

sf apex run test --target-org demo --tests DispatchServicesTest --tests CaseRouterTest --tests VoiceCallIntakeTest --tests SilentAlarmIntakeTest --tests AgentEmergencyIntakeTest --result-format human --wait 5
Hold on the table. All ten pass, in under two seconds.

‘Those are the ones that matter — the two intake paths and the silent path landing P0 are
what would break first if someone changed the table or the scoring weights.

The journal's in the repo too, in order, including what broke. Restore the browser.’


-->

---

## What broke, and what it taught

- A 17-character queue ID hid behind missing fault connectors: two hours
- `Is Null` returned false against a null DateTime: replaced with ISBLANK
- An Apex action that never invoked: replaced with a flow action
- A queue view that couldn't show new Cases: the "no case" reports were the list's fault

<!--
<!--
Four things.

A queue ID off a URL was seventeen characters and hid behind missing fault connectors for
two hours. Is Null evaluated false against a null date. An Apex action never fired and it
was the binding. The list view couldn't show new Cases, so half my "it's broken" was the
list lying to me.

Fault connectors on every DML element. Never hand-type an ID. Verify the instrument before
trusting it.
-->

-->

---

## Rollout

1. Connect and PSTN, one building
2. Routing table to production, zone derived from building
3. Screen pop to the dispatch desk, with empty and error states
4. Escalation with a real on-call rota
5. 911 bridge and E911 address data
6. Agent on voice, after the classifier is tuned on real calls

<!--
"One building first. The table and the pop are the value; telephony is procurement. Connect
and PSTN after that, then the table to production with zone derived from building, then the
pop to the desk, then escalation on a real on-call rotation, then 911 and E911 data, and the agent on
voice last, once the classifier's been tuned on real calls."

-->

---

## What I'd need from you

- Access to the existing PoC
- The queue and skill model dispatch actually uses
- Whether 911 bridging is in scope, or a later phase
- A named on-call rota for escalation

<!--
Access to the existing PoC. The queue and skill model dispatch actually uses. Whether 911
bridging is in scope or a later phase. A named on-call rotation for escalation.

Ask, then let the room answer. Don't fill the silence.
-->

---

<!-- _class: lead -->
<!-- _backgroundImage: url('img/hero.jpg') -->
<!-- _backgroundSize: cover -->
<!-- _backgroundOpacity: 0.45 -->
# Working proof, in two days

### The gap list is written down. Let's talk about which parts you want first.

<!--
Two days, and the gap list is written down.

Tell me which parts you want first.

Stop talking. Let them ask.
-->