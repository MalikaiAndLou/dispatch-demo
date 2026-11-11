# Dispatch demo — review packet

## Note

The technical interview is where a candidate describes work. This puts the work in front of
you first, so the interview can be about the decisions rather than the pitch.

Two days, one Developer Edition org, and a journal of every wrong turn. Nothing here is a
mock-up: the routing table, the trigger, the agent and the screen pop all run.

## Access

Repository: https://github.com/MalikaiAndLou/dispatch-demo — public, no invite needed.

Start with `docs/build-report.md`. It has the architecture, the component inventory, the
decisions and an explicit list of what a production system adds that this doesn't.

Then read `journal/` in numeric order. It is honest. Journal 0011 is two hours lost to a
17-character queue ID; 0018 is three hours on an agent action that never invoked. The
journal is the part that shows how the work actually goes.

## Recording

https://1drv.ms/v/c/b005b7016cab663b/IQC7h3d9hIePQY33Ek4YQhRgAY-iEvIgTAVm4eVKk_gPM3c?e=by3dHl

Fourteen minutes, no editing, one take. It runs the silent alarm path, the voice path, the
agent, a live routing change with no deployment, and the escalation timer.

## Walkthrough

Timestamps are approximate; scrub if one lands a few seconds early.

| Time | Beat |
|---|---|
| 0:00 | The problem, and what an emergency line has to survive |
| 1:25 | Where a PoC stops and go-live begins |
| 2:55 | Silent alarm, live: duress button, RED panel, P0 in Duress |
| 4:40 | The screen pop, and why the badge is on the record |
| 5:40 | Voice call, live: DNIS resolves the building |
| 7:00 | The agent, live: free text to routed Case |
| 8:40 | The agent as a single front door for every channel |
| 9:20 | Live metadata edit — Case rerouted with no deployment |
| 11:00 | Escalation: unclaimed P0 re-owned after two minutes |
| 11:50 | Ten test methods, all passing |
| 12:40 | What broke, and what it taught |
| 13:15 | Rollout order, and what I'd need from you |

## What is real, what is simulated

Real: routing, the metadata table and its fallback, the trigger, the agent and its action,
the screen pop, the escalation path, the tests.

Simulated: telephony. There is no Amazon Connect and no PSTN in this org, so the voice leg
is a Screen Flow and the agent is demonstrated over messaging. `docs/build-report.md`
section 9 lists every remaining gap — Omni-Channel presence, audible alerting,
accept/decline, supervisor tools, 911 egress.

## Live demo

Available if you want it. I'd rather run it live than have you take the recording's word for
it, and you can pick the scenario.

## What I'd want to know

- What the existing PoC already does, so this doesn't duplicate it
- The queue and skill model dispatch actually uses
- Whether 911 bridging is in scope or a later phase
- Who holds the on-call rotation

Daniel Cadwell