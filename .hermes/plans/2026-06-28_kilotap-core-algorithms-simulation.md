# KiloTap Core Algorithms Simulation — Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.
> **Approval:** Commander's review required before execution. Changes expected.

**Goal:** Build an interactive web-based simulation that demonstrates KiloTap's two core algorithms — Spatial Area Ratio (Ω) and Haversine Proximity Sorting — with live Google Maps, simulated YOLO bounding boxes, and real-time calculations.

**Architecture:** Single-page HTML/JS application. Google Maps embedded with draggable markers. Canvas-based YOLO simulation with adjustable bounding boxes. All math (Ω ratio, Haversine distance) computed client-side in real-time. No backend — fully portable.

**Tech Stack:** HTML5, CSS3, Vanilla JavaScript, Google Maps JS API, Canvas API

**Deploy Target:** Save to `/root/kilotap-simulation/` → push to `madarax092/kilotap-simulation` repo → optionally host on GitHub Pages.

---

## Simulation Screen Layout

```
┌─────────────────────────────────────────────────────────┐
│  KILOTAP — Core Algorithms Simulation                    │
├──────────────────────┬──────────────────────────────────┤
│                      │                                  │
│   📸 YOLO SIMULATOR  │   🗺 GOOGLE MAP + HAVERSINE      │
│                      │                                  │
│   [Scrap pile image] │   [Interactive Google Map]       │
│   with editable      │   • 🏠 Household marker (drag)   │
│   bounding boxes     │   • 🛺 Collector markers (drag)  │
│                      │   • 📏 Distance lines            │
│   ┌──────────┐       │                                  │
│   │ Detected  │       │   Collectors sorted by distance: │
│   │ Items:    │       │   1. Mang Juan — 0.42 km 🛺     │
│   │ PET bottle│       │   2. Mang Pedro — 1.83 km 🚛    │
│   │ Cardboard │       │   3. Mang Luis — 3.15 km 🛺     │
│   │ ScrapMetal│       │                                  │
│   └──────────┘       │                                  │
│                      │                                  │
├──────────────────────┴──────────────────────────────────┤
│  📊 LIVE CALCULATIONS DASHBOARD                          │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────────┐  │
│  │ Ω = 0.34    │ │ Vehicle: 🛺   │ │ Closest: 0.42 km │  │
│  │ τ = 0.40    │ │ Sidecar OK   │ │ Mang Juan         │  │
│  │ Ω < τ ✓     │ │              │ │ (compatible)      │  │
│  └─────────────┘ └──────────────┘ └──────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Team Composition (3 Subagents)

| Agent | Specialization | Responsibilities |
|-------|---------------|-----------------|
| **Agent Alpha** | Frontend / Layout | HTML structure, CSS styling, Google Maps integration, dashboard UI |
| **Agent Beta** | Haversine / Maps | Haversine formula, collector data model, marker management, distance sorting, Firebase-like filtering simulation |
| **Agent Gamma** | YOLO / Spatial Math | Canvas-based bounding box editor, scrap image, Ω calculation, vehicle decision logic, detection table |

---

## Task Breakdown

### PHASE 1: Project Scaffold

#### Task 1.1: Create project directory and HTML shell
- **Create:** `/root/kilotap-simulation/index.html`
- Single HTML file with DOCTYPE, meta viewport, dark theme CSS variables
- Placeholder divs for: YOLO panel, Map panel, Dashboard panel
- No logic yet — pure structure + responsive grid layout

#### Task 1.2: Create assets directory with sample scrap image
- **Create:** `/root/kilotap-simulation/assets/`
- Generate a simple placeholder scrap pile image (or use a canvas-generated one)
- CSS file for styling (linked or embedded)

### PHASE 2: Google Maps + Haversine (Agent Beta)

#### Task 2.1: Embed Google Maps with household and collector markers
- Google Maps JS API loaded with `loading=async`
- One household marker (🏠, blue, draggable)
- Three collector markers (🛺 or 🚛, orange, draggable)
- Each collector has a data model: `{ id, name, vehicleType, lat, lng, online }`
- Map auto-centers on Davao City coordinates (~7.07°N, 125.61°E)

#### Task 2.2: Implement Haversine distance calculation
- Pure JS function `haversine(lat1, lng1, lat2, lng2)` → distance in km
- Implements the formula: a = sin²(Δφ/2) + cos(φ₁)cos(φ₂)sin²(Δλ/2), c = 2·atan2(√a, √(1-a)), d = R·c
- R = 6371 km constant
- Unit tests via console.assert or inline verification

#### Task 2.3: Real-time distance sorting and collector panel
- On any marker drag: recalculate all distances, resort, update panel
- Collector panel shows: name, vehicle type icon, distance (km), compatible/incompatible badge
- Sort by distance ascending
- Grey out incompatible collectors (wrong vehicle type)

#### Task 2.4: Distance lines on map
- Draw polylines from household to each collector
- Line color: green = closest compatible, orange = compatible, grey = incompatible
- Line label shows distance in km

### PHASE 3: YOLO Simulator + Spatial Math (Agent Gamma)

#### Task 3.1: Create canvas-based scrap image viewer
- Canvas element displaying a sample scrap pile image
- Image: generated procedurally (colored rectangles representing scrap items) or a static asset
- Canvas sized to ~400×300 pixels

#### Task 3.2: Implement editable bounding boxes
- Pre-loaded bounding boxes (3-5 objects) drawn on the canvas
- Each box = { xmin, ymin, xmax, ymax, label, confidence }
- Boxes are draggable/resizable (corner handles)
- Add/remove boxes via controls
- Labels: PET bottle, Cardboard, Scrap Metal, Aluminum Can, etc.
- Confidence slider per box (0.5 – 1.0)

#### Task 3.3: Implement Spatial Area Ratio (Ω) calculation
- Function `calculateOmega(bboxes, canvasWidth, canvasHeight)` → Ω
- Σ(bounding box areas) ÷ (W × H)
- Live-updating Ω display
- Pre-configured threshold τ = 0.40 (adjustable via slider)

#### Task 3.4: Vehicle requirement decision logic
- Function `determineVehicle(omega, tau, bboxes)` → VehicleType
- Logic: IF Ω ≥ τ OR any oversized label (refrigerator, washing_machine) with confidence ≥ 0.85 → haulingTruck, ELSE tricycleSidecar
- Visual: green badge for sidecar, orange badge for truck
- Oversized items trigger a warning indicator

### PHASE 4: Dashboard + Integration (Agent Alpha)

#### Task 4.1: Build live calculations dashboard
- Three card panels showing: Ω value vs τ, Vehicle decision, Closest collector
- All values update in real-time on any change (bbox resize, marker drag, τ slider)
- Color coding: green = within limits, red/orange = override triggered

#### Task 4.2: Wire YOLO panel → Vehicle requirement → Map filtering
- When Ω or oversized detection changes → update VehicleRequirement
- VehicleRequirement flows to Haversine filtering
- Incompatible collectors greyed out on map + panel
- "Vehicle Required" badge updates in real-time

#### Task 4.3: Add scenario presets
- 3 preset buttons:
  1. "Small Load" — ~15% Ω, small items → sidecar match
  2. "Medium Load" — ~35% Ω, mixed items → sidecar match (borderline)
  3. "Heavy Load" — ~55% Ω + refrigerator → truck required
- Each preset loads specific bounding box configuration
- Demonstrates the decision threshold

#### Task 4.4: Polish and responsive design
- CSS animations for distance updates
- Mobile-responsive layout (stack panels vertically on narrow screens)
- Loading state for Google Maps
- Error handling for missing API key
- Footer with team credits and links

### PHASE 5: Testing & Deployment

#### Task 5.1: Manual verification checklist
- [ ] Dragging household marker updates all distances
- [ ] Dragging collector marker updates its distance
- [ ] Changing Ω (resizing boxes) updates vehicle decision
- [ ] τ slider changes the threshold
- [ ] Oversized item with confidence ≥ 0.85 forces truck
- [ ] Closest compatible collector highlighted
- [ ] Incompatible collectors greyed out
- [ ] Scenario presets work correctly
- [ ] Mobile layout doesn't break

#### Task 5.2: Deploy to repo
- Commit all simulation files
- Push to `madarax092/kilotap`
- Optionally enable GitHub Pages for live demo

---

## Files That Will Be Created

| File | Purpose |
|------|---------|
| `/root/kilotap-simulation/index.html` | Main application (HTML + CSS + JS in one file) |
| `/root/kilotap-simulation/assets/scrap-pile.png` | Sample scrap image for YOLO simulator |
| `/root/kilotap-simulation/README.md` | How to run, API key setup, architecture notes |

---

## Google Maps API Key

**Required:** A Google Maps JS API key with Maps JavaScript API enabled.

The simulation will use a placeholder. To run with a real map:
1. Get a key from https://console.cloud.google.com/google/maps-apis
2. Enable "Maps JavaScript API"
3. Replace `YOUR_API_KEY` in the HTML file

Without a key, the map will show a placeholder with simulated coordinates.

---

## Risks & Tradeoffs

| Risk | Mitigation |
|------|-----------|
| Google Maps API key exposure in client-side code | Use API key restrictions (HTTP referrer) |
| Canvas bbox editing complexity | Pre-loaded presets + simple drag handles (not full annotation tool) |
| Single HTML file gets too large | Keep under 1000 lines; split to CSS/JS files if needed |
| Mobile usability | Stack layout vertically; keep touch targets ≥ 48px |

---

## Open Questions for Commander

1. **Google Maps API key** — Do you have one, or should I build the simulation to work with a placeholder map?
2. **Scrap pile image** — Should I generate a procedural one (colored shapes), use a stock photo, or do you have an image to use?
3. **Deployment** — Push to the `kilotap` repo? Enable GitHub Pages for a live demo?
4. **Davao City specific** — Pre-load real Davao barangay coordinates for authenticity, or keep it generic?
