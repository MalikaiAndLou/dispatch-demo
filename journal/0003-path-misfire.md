---
date: 2026-11-08
phase: build
type: surprise
---

## What happened

Repo created at `C:\Users\dcadw\js-ramp\dispatch-demo` instead of `C:\Users\dcadw\dispatch-demo`. `New-Item` ran with the cwd inside `js-ramp`, so the relative path resolved there. Move then failed on a lock held by the open editor window.

## Decision

Moved to `C:\Users\dcadw\dispatch-demo`. Nothing lost.

## Why

Two nested git repos is a real annoyance, not cosmetic.

## What it costs

Twenty minutes.

## Follow-up

`pwd` before anything that creates files. Close the editor before moving a folder.
