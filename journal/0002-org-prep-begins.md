---
date: 2026-11-08
phase: build
type: decision
---

## What happened

Scaffolding step.

## Decision

Build objects and fields exactly as specified so later steps drop in without a rename sweep.

## Why

Apex and Flow references are hardcoded to these API names.

## What it costs

Rigid. If a name changes, it changes now.

## Follow-up

Confirm Omni-Channel present before anything else.
