---
name: run-kilotap-qa
description: Run KiloTap's QA smoke check - flutter analyze, a debug APK build, and a requirements-gap report against the G16 paper. Use when asked to run QA, verify the app builds, check code quality, do a smoke test, or confirm whether KiloTap still meets its documented requirements.
---

# KiloTap QA smoke check

Paths below are relative to the repo root (`C:\Users\kennu\kilotap`), not this skill directory.

This is a native Windows + Flutter project (not a container/GUI app) — no xvfb, tmux, or browser driver needed. The "driver" is a plain build/analyze pipeline run through the Bash tool (Git Bash). Verified in this session: `flutter pub get`, `flutter analyze` (clean, ~26s), and `flutter build apk --debug` (succeeds, ~3m40s, mostly the Gradle task) all work as-is with no setup beyond what's already on this machine (Flutter SDK on PATH, Android toolchain, `android/app/google-services.json` present).

## Prerequisites

None beyond what's already configured on this machine: `flutter` on PATH, `android/app/google-services.json` and `lib/firebase_options.dart` present (both gitignored, must exist locally to build).

## Run (agent path)

```bash
bash .claude/skills/run-kilotap-qa/smoke.sh
```

Run this with the Bash tool using a timeout of at least 300000ms (5 min) — the build step alone took 3m40s on first run; a warm Gradle cache is faster but don't assume it.

What it does, in order:
1. `flutter pub get`
2. `flutter analyze` — must report "No issues found!" to pass
3. `flutter build apk --debug` — must produce `build/app/outputs/flutter-apk/app-debug.apk`
4. Prints `PASS` or `FAIL` with a log excerpt on failure
5. Deletes its own temp log file (`mktemp`) — nothing is left behind in the repo; `git status --short` should be unchanged by a run (aside from files already dirty going in)
6. Prints a manually-maintained "Known gaps vs. G16 paper requirements" section — this is the answer to "does it meet the requirements": analyze+build passing means the code compiles and is lint-clean, but does **not** mean the documented functional requirements are met. Cross-check this list against CLAUDE.md's Architecture section when reporting results, since it can drift out of date.

Exit code is 1 if any check failed, 0 otherwise.

## Run (human path)

Same commands, run manually one at a time if you want to watch each step individually rather than through the script: `flutter pub get && flutter analyze && flutter build apk --debug`.

## Gotchas

- The build prints a "Kotlin Gradle Plugin" deprecation warning (`google_maps_flutter_android` applies KGP) — this is expected and non-fatal, not a failure. Don't treat build warnings in the Gradle output as a FAIL; only a non-zero exit from `flutter build apk` is a real failure.
- The build step is slow (minutes, not seconds) because it invokes Gradle's `assembleDebug` task. Don't shrink the Bash timeout below ~5 minutes or the run will be killed mid-build and falsely look like a hang.
- `flutter pub outdated` will show ~40 packages with newer versions available — this is informational only from `pub get`, not a failure signal.
