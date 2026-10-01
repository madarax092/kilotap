# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

KiloTap is a Flutter/Firebase mobile app: a two-sided recyclable-scrap marketplace connecting Households (sellers, who book scrap pickups) with Collectors (buyers, who accept and haul the scrap) in Davao City, Philippines, plus an Admin role for verification and moderation. It is a BSIT capstone project written up as a G16 ACM paper. **It is a logistics-matching platform, not a pricing app** — there is no in-app pricing, payment, or price-directory feature; the financial transaction happens person-to-person after pickup. Do not add pricing/payment features unless explicitly asked.

`README.md` describes an earlier prototype design (Riverpod, go_router, a `market_prices` collection) that no longer matches the code — see Architecture below for what's actually implemented.

## Commands

```powershell
flutter pub get              # install dependencies
flutter analyze              # static analysis — must be 0 errors/0 warnings before considering work done
flutter run -d <device-id>   # run on a connected/emulated device
flutter clean                # clean build artifacts (use before a build after dependency/Gradle changes)
```

There is no test suite (`test/` is empty) — do not assume `flutter test` covers anything.

Firestore seed data used during development is (re)created with `python3 scripts/recreate_firestore.py`. It wipes and reseeds `UserAccount`, `bookings`, `bookingItems`, `ratings`, `notifications`, `auditLogs`, and `scrapWeights` using a service-account JSON path that only exists on the server (`/root/.hermes/firebase/...`) — treat it as a reference for the schema, not something to run casually.

Firebase config: `firebase.json` targets Firebase project `kilotap-prototype`. `android/app/google-services.json` and `lib/firebase_options.dart` are required to build/run and are gitignored — obtain them locally rather than recreating them from scratch.

## Architecture

**Navigation & auth**: There is no router package — `lib/router.dart` is a hand-rolled `switch` on route-name strings inside `AppRouter.generateRoute`, gating every route through `AuthState.instance.canAccess(route)`. `lib/services/auth_state.dart` is a singleton holding the signed-in user's role (`Household`/`Collector`/`Admin`) and denormalized profile fields (populated on sign-in, cleared on `logout()`). `lib/services/role_permissions.dart` maps each role to a set of permission strings and each route to the permission it requires (`RolePermissions.canAccessRoute` / `hasPermission`); `Admin` bypasses all per-route checks. There's a `VerifiedCollector` role tier in `role_permissions.dart` that grants `acceptPickup` in addition to what plain `Collector` gets, though `AuthState.isCollector`/`isAdmin`/`isHousehold` only distinguish the three top-level roles.

**Data layer**: Everything is Firestore-backed via `StreamBuilder` — there is no local/demo data path. `lib/services/firestore_service.dart` is the single access point: booking streams (`sellerBookings`, `collectorBookings`, `availableBookings`), `bookingItems(bookingId)`, chat (`sendMessage`, `messagesBetween`, `userConversations`), admin queries (`listUsers`, `pendingCollectors`), and name-join helpers. `createBooking()`/`createBookingItem()` exist on the service but are not yet wired into any screen — the "Book Now" flow currently ends at a static confirmation UI with no actual Firestore write; this is the single biggest functional gap in the app. Firestore persistence is enabled app-wide in `main.dart` (`persistenceEnabled: true`, 100MB cache), and `lib/services/cache_service.dart` (Hive) backs offline fallbacks.

**Firestore schema** follows the paper's Tables 7–15 exactly, and field names must not be renamed: `UserAccount/{uid}` (Table 7, common account fields incl. `Role`) → subcollections `ScrapSeller` (Table 8) and `ScrapCollector` (Table 9, incl. `Vehicle_Type`, `Vehicle_Capacity_Kg`, live `Current_Latitude`/`Current_Longitude`); `bookings/{Booking_ID}` (Table 10) → subcollection `bookingItems/{Item_ID}` (Table 11); `scrapWeights/{Class_Name}` (Table 12, the weight-lookup reference table); `ratings/{Rating_ID}` (Table 13); `auditLogs/{Log_ID}` (Table 14); `notifications/{Notification_ID}` (Table 15). A `messages/{Message_ID}` collection backs chat but is intentionally *not* one of the numbered paper tables.

**Detection → dispatch pipeline** (models are: `lib/services/ml/*`, `lib/services/scrap_weight_service.dart`, `lib/services/ml/capacity_matcher.dart`, `lib/services/google_maps_service.dart`):
1. A household photo goes through an on-device YOLOv8n model (TFLite) to produce class labels — `lib/services/ml/tflite_runner.dart`, `detection_postprocess.dart`, `molo_architecture.dart`, and `pipeline.dart` are the wiring for this, but **the model is not yet trained**, so detection currently returns no items. Don't treat this pipeline as functional end-to-end without checking whether it's still stubbed.
2. `ScrapWeightService` does a static class-name → weight/size-class lookup (backed by the `scrapWeights` collection, 33 classes).
3. `CapacityMatcher.match()` (`lib/services/ml/capacity_matcher.dart`) turns total kg into a `VehicleSize` by fixed thresholds — `<20kg` Pushcart, `<100kg` Tricycle Sidecar, `<500kg` Multicab, else Truck — then bumps the result up one tier if any item's size class is `"Heavy Override"` (capped at Truck), regardless of total weight. This is the "recommend, don't enforce" rule: the collector still makes the final call.
4. `GoogleMapsService.getRoute()` (`lib/services/google_maps_service.dart`) calls the Distance Matrix API for driving distance/ETA between two coordinates, with an Hive-backed LRU cache (`route_cache` box, 20 entries) as an offline/no-key fallback — it explicitly checks for the literal placeholder value `AppConstants.googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY'` and skips the network call in that case. `lib/services/routing_service.dart` sits above this for higher-level routing/ranking use. `lib/core/constants/app_constants.dart` holds the key — it is tracked in git with the placeholder value; a real key is only ever added there as an uncommitted local edit and must never be pushed.

**Screens** are organized by role under `lib/screens/{account,household,collector,admin}/`, one screen per file, wired into `router.dart` by route-name string. `lib/core/theme/app_colors.dart` and `lib/core/constants/app_constants.dart` hold the shared color tokens (flat palette, no gradients — Seller Green `#1B8A5A`, Buyer Blue `#1A85C8`) and shared enums (`vehicleTypes`, booking/verification status strings, Firestore collection name constants). The collector-facing UI shows weight in kilos only, never currency — pricing/payment is out of scope.

## Conventions

- No emojis anywhere (code, comments, UI text, commit messages). No gradients — flat colors only.
- `flutter analyze` clean (0 issues) before calling work done.
- Prefer block-body `{ return ...; }` over arrow-body (`=>`) for any widget tree longer than ~2 lines.
- Wrap `ListTile` in `Material`, never `Container` + `BoxDecoration` (breaks ink splash / asserts on Flutter Web).
- One screen = one `.dart` file. No duplicate logic — extract shared helpers.
- Files under `lib/screens/household/` and `lib/screens/collector/` import shared code via `../../core/`, `../../services/`, `../../models/`.
- Vehicle types are exactly `Pushcart`, `Tricycle`, `Multicab`, `Truck` (no parenthetical descriptions in UI); size classes are `S`/`M`/`L`/`Heavy Override` (no raw kg as the primary display).
- Flutter 3.44 renames — don't reintroduce the old names: `withOpacity` → `withValues(alpha:)`, `activeColor` (Switch/Radio) → `activeThumbColor`, `CardTheme` → `CardThemeData`. `borderLeft` isn't a valid `BoxDecoration` param — use `border: Border(left: ...)`.
- Don't combine Firestore `array-contains` with `orderBy` on a different field (forces a composite index) — sort in Dart instead.
- On Flutter Web, edge-to-edge headers break `SafeArea`/`AppBar`/`PreferredSize`; use `Column` + `Container(padding: EdgeInsets.only(top: MediaQuery.padding.top + 16))` + `Expanded(ListView)` instead, wrapping only the bottom nav in `SafeArea`.
- Removing a class field needs a hot restart (`R`) — hot reload (`r`) won't pick it up.

## Workflow

**Before making any code or design change, no matter how small, run this checklist and get explicit go-ahead — do not edit files first and explain after:**
1. State what the change is and why, in a sentence or two.
2. Check it against this file's "What this is" section — confirm it doesn't drift into pricing/payment/rate-directory territory or otherwise stray from the logistics-matching purpose.
3. Check it against the relevant doc source: this file's Architecture/Schema section for anything touching data models, routing, or the detection pipeline; the G16 ACM paper (Tables 7-15, the requirements in §2.1.3, the vehicle-capacity thresholds in §2.3.2.2) for anything that should match the paper's spec.
4. Present a short plan (what files, what changes) and wait for the user's explicit approval before editing.
5. Do not push to git without separate explicit approval, even after an edit was approved — treat push as its own gated action, not implied by an approved edit.

This supersedes any earlier "just make the change" default — always plan, verify, and ask first here, for every change.

- Never edit `.dart` files with a code-execution/eval tool — it has corrupted source before (merged imports into widget code, broken string literals). Use a full-file rewrite or a targeted diff-style edit instead. After 3+ failed patch attempts on one file, stop patching and rewrite it clean.
- Before pushing, verify bracket balance (`(`/`)`, `{`/`}`) on every changed file, and never push code known to be broken.
- Prefer the simpler fix — removing a problematic feature over adding complexity to accommodate it.
- Never commit `google-services.json` or `firebase_options.dart` (Firebase credentials, gitignored). Never push a real Google Maps API key — `lib/core/constants/app_constants.dart` must keep the `YOUR_GOOGLE_MAPS_API_KEY` placeholder in the repo; a real key is a local-only, uncommitted edit.
