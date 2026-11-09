---
date: 2026-11-09
phase: build
type: decision
---

## What happened

Mid-build, asked why labels and API names are being kept deliberately different
rather than just underscores. Ten years of habit has been "make sure the __c is there".

## Decision

Label is human language, sentence case, editable at will. API name is a short
permanent technical key: scrDone, txtResult, actCreate, decScore. Type prefix plus
purpose.

## Why

- The API name is immutable once referenced. The label is not. Splitting them means
  a relabel never becomes a rename.
- Labels are read by users and admins. API names are read by machines, merge fields,
  change sets, debug traces and stack traces. They serve different readers.
- Underscores encode nothing. scrDone / actCreate encode element type and intent, so
  the canvas and the trace are legible before you read the label.
- Fields are the opposite case: the API name is what code touches and what is
  permanent, so __c and underscore hygiene is mandatory there.

## What it costs

- Two strings to maintain per element instead of one.
- Reads as overkill on a two-day demo, pays off on anything that survives a year.
- Inconsistent with the rest of this org, which uses label-equals-name throughout.
  A reviewer will notice the mismatch; that is a talking point, not a defect.

## Follow-up

Keep the convention for new elements. Do not retrofit old ones mid-demo.
