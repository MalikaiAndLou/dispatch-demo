---
date: 2026-11-10
phase: build
type: surprise
---

## What happened

Moving the source into the repo for the interview artifact. The org was created
through Trailhead and the user has no password, so CLI auth had to be solved first.

## Sequence

1. `sf org login web` opened the username chooser. The org's username
   (dancadwell.40cb0dcbca2b@agentforce.com) was not in the saved list.
2. Chose "log in as another user" and generated a temporary password from Setup →
   Users → Edit → Generate new password. No email dependency.
3. Login reached the OAuth approval screen and errored. Not the password.
4. Installed Salesforce CLI on the org's Connected Apps page — the app was listed but
   not installed, so the approval had nothing to approve.
5. CLI was on an old version without a device flow. Upgraded to @salesforce/cli 2.157.8.
   npm postinstall scripts were blocked; harmless.
6. Approval still failed. Root cause: Connected App policy had IP Relaxation set to
   "Enforce IP restrictions". Changed to "Relax IP restrictions".
7. `sf org login web --alias demo` then succeeded.

## Why it matters

None of this was Salesforce-specific knowledge. It was reading an error, checking the
most likely policy, and working through it in order. The password step is the one worth
remembering: a Trailhead-created org has no password and its agentforce.com username
often cannot receive mail, so the temp password from the User record is the only route
in without an email round trip.

## What it costs

- About twenty minutes, most of it on the OAuth error.
- The org's Connected App policy is now relaxed. Fine for a demo org, worth tightening
  in anything real.
- A temporary password now exists on the admin user and should be changed.

## Follow-up

Retrieve the source. Change the admin password after the interview.
