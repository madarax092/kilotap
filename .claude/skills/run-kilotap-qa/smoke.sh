#!/usr/bin/env bash
# KiloTap QA smoke check: pub get -> flutter analyze -> debug APK build,
# then a manually-maintained requirements-gap report.
# Run from repo root: bash .claude/skills/run-kilotap-qa/smoke.sh
set -uo pipefail

LOG=$(mktemp)
PASS=1

echo "=== KiloTap QA smoke check ==="
echo "(log: $LOG — deleted automatically at the end of this run)"

echo ""
echo "--- flutter pub get ---"
if flutter pub get >>"$LOG" 2>&1; then
  echo "OK"
else
  echo "FAIL — see log excerpt below"
  tail -20 "$LOG"
  PASS=0
fi

echo ""
echo "--- flutter analyze ---"
if flutter analyze >>"$LOG" 2>&1; then
  tail -3 "$LOG"
else
  echo "FAIL — see log excerpt below"
  tail -40 "$LOG"
  PASS=0
fi

echo ""
echo "--- flutter build apk --debug (takes ~3-4 min, mostly the Gradle task) ---"
if flutter build apk --debug >>"$LOG" 2>&1; then
  echo "OK — build/app/outputs/flutter-apk/app-debug.apk"
else
  echo "FAIL — see log excerpt below"
  tail -60 "$LOG"
  PASS=0
fi

echo ""
echo "=== Result ==="
if [ "$PASS" -eq 1 ]; then
  echo "PASS — analyze clean, debug APK builds."
else
  echo "FAIL — one or more checks failed above. Full log was: $LOG"
fi

rm -f "$LOG"

echo ""
echo "=== Known gaps vs. G16 paper requirements (manually maintained — cross-check against CLAUDE.md) ==="
cat <<'EOF'
- Booking write: createBooking()/createBookingItem() exist in firestore_service.dart but no
  screen calls them — the "Book Now" flow ends at a static confirmation with no Firestore write.
  (Undermines FR 2.1.3.1.4 On-Demand and Scheduled Booking Selection — booking never persists.)
- MOLO/YOLOv8n detection: architected (lib/services/ml/*) but not trained — detection returns
  no items. (FR 2.1.3.1.3 Intelligent Scrap Ingestion is stubbed, not functional.)
- Google Maps API key: shared/repo copy keeps the YOUR_GOOGLE_MAPS_API_KEY placeholder by design
  — live routing/ETA (FR 2.1.3.1.5, FR 2.1.3.1.11) only works with a real local key.
- Firebase Storage photo upload not wired — the household's scrap photo stays on-device, so the
  collector never sees the real photo (referenced in Figure 22/25 prototypes).
- Analytics aggregates (lib/screens/analytics_screen.dart) are hardcoded, not computed from real
  booking/rating data.
EOF

[ "$PASS" -eq 1 ] || exit 1
