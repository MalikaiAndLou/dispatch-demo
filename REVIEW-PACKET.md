# Dispatch demo — review packet

## Note

The technical interview is where a candidate describes work. This puts the work in front
of you first, so the interview can be about the decisions rather than the pitch.

Two days, one Developer Edition org, and a journal of every wrong turn. Nothing here is
a mock-up: the routing table, the trigger, the agent and the screen pop all run.

## Access

Repository: https://github.com/MalikaiAndLou/dispatch-demo — public.

Start with `docs/build-report.md`. It has the architecture, the component inventory, the
decisions and an explicit list of what a production system adds that this doesn't.

Then read `journal/` in numeric order. It is honest. Journal 0011 is two hours lost to a
17-character queue ID; 0018 is three hours on an agent action that never invoked. The
journal is the part that shows how the work actually goes.

## Recording

`<recording-link>` — ten minutes, no editing. It runs the silent alarm path, the voice
path, the agent, a live routing change with no deployment, and the escalation timer.

## Walkthrough

| Time | What you'll see |
|---|---|
| 0:00 | The problem, and why it's additive to your PoC |
| 1:00 | Three entry points, one router |
| 1:40 | Silent alarm: RED panel, NO SIGNAL, Duress at P0 |
| 3:00 | Voice call: DNIS resolves the station, routes on FIRE / MB-03 |
| 4:20 | The agent: free text classified, Case created and routed |
| 6:00 | Metadata edit, live: ASSAULT/MB-03 moved, reroutes with no deploy |
| 7:20 | Escalation: unclaimed P0 re-owned after two minutes |
| 8:00 | Ten test methods, all passing |
| 8:40 | What broke and what it taught |

## What is real, what is simulated

Real: routing, the metadata table and its fallback, the trigger, the agent and its
action, the screen pop, the escalation path, the tests.

Simulated: telephony. There is no Amazon Connect and no PSTN in this org, so the voice
leg is a Screen Flow and the agent is demonstrated over messaging. `docs/build-report.md`
section 9 lists every remaining gap — Omni-Channel presence, audible alerting,
accept/decline, supervisor tools, 911 egress.

## Live demo

Available if you want it. I'd rather run it live than have you take the recording's word
for it, and you can pick the scenario.

## What I'd want to know

- What the existing PoC already does, so this doesn't duplicate it
- The queue and skill model dispatch actually uses
- Whether 911 bridging is in scope or a later phase
- Who holds the on-call rota

Daniel Cadwell