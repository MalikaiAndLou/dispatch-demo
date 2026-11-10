# Recording script — 10 minutes

Rule: never narrate a click you haven't done. Never say "as you can see" about something
off screen. If something fails, keep going and say what failed.

## 0:00 — Cold, no screen
"There's smoke in a stairwell on a university campus. Someone has to decide, in seconds,
which team goes and how fast. I built the parts that decision depends on."

## 0:20 — Slide 3, the PoC-to-go-live table
"I haven't seen your PoC, so this is additive. These are the gaps between a demo and a
campus running it. I built working versions of the hard ones in two days so you can judge
the skill."

## 1:00 — Architecture slide
"Three doors, one router. Voice call, silent alarm, agent text — all land on the same
CaseRouter, which reads one metadata table. The router is the only thing that decides,
so behaviour is auditable in one place."

## 1:40 — Silent alarm, live
Open Silent Trigger Intake. Station `MB-BY-BL02`. Run.
"The alarm carries only a location. Case created, ASSAULT, anonymous, no PHI."
Open the Case. Panel is RED, camera blacked out.
"Station's out of service. The alarm still routes — a dead camera doesn't suppress it.
Duress queue, P0, two minutes until it escalates."

## 3:00 — Voice call, live
Open Voice Call Intake. `4155550103`, FIRE, injured unticked. Run.
"DNIS resolves the station, intent is captured, a score drives severity. Lands on Campus
Emergency Dispatch, FIRE / MB-03, P1."
Open the Case. Green badge, live camera.

## 4:20 — The agent, live
Switch to the agent tab, fresh session.
Type: `smoke coming from the stairwell in Byers Hall`
"Free text. It classifies, asks location and injury, then creates and routes the Case
through the same table. Reads the number back."
Show the Case.

## 6:00 — Metadata edit, live
Routing Map, `ASSAULT_MB_03`, queue to `00GjV00000354yvUAA`. Save.
Rerun silent flow with `MB-BY-BL02`.
"Facilities instead of Duress. No deployment, no restart. That's the table."
Change it back.

## 7:20 — Escalation
"While that ran, the earlier P0 hit two minutes and re-owned to a named dispatcher with
ESCALATED stamped. Nobody picks it up, it doesn't sit there."

## 8:00 — Tests
Show the 10/10 run.
"Ten methods. DNIS normalisation, scoring weights, exact and fallback routing, both
intake paths, the silent path landing P0."

## 8:40 — What broke
"Four things broke. A queue ID typed from a URL was 17 characters and hid for two hours
behind missing fault connectors. Is Null returned false against a null DateTime. An Apex
action never invoked. The queue view couldn't show new Cases, so several 'no case' reports
were the list's fault, not the code's. Each one is a lesson, and each is in the journal."

## 9:20 — Gaps and close
"No Connect, so voice is simulated and the agent is messaging. Queue ownership isn't
paging. IDs not names in the table. Those are the next four weeks, listed in the report.
Working proof of the hard parts, in two days, with the gap list written down."