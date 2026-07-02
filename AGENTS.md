# KiloTap — Agent Rules

## CRITICAL: Git & Push Rules
- **NEVER push without running `bash test/validate.sh` first** — 14 automated checks must pass
- **NEVER push to any git repo without explicit user permission** — ask first, every time
- If debugging cycle exceeds 5 patches for the same root cause, STOP and rebuild from scratch
- Commits use conventional commits: `fix:`, `feat:`, `refactor:`, `docs:`, `chore:`
- Repos: `madarax092/kilotap` (Flutter app) and `madarax092/kilotap-simulation` (algo demo) — separate repos

## Code Style
- Execute immediately — never ask "want me to apply this?" for understood changes
- No code previews or ghost text — just do it and report results
- Verify fixes before claiming success
- Simple, minimal fixes — remove features over adding complexity
- Self-contained single HTML files with no external dependencies
- For Flutter: `flutter clean` → `flutter pub get` → `flutter run -d chrome`
- For JS/HTML: `npx fallow health` + `npx prettier --check` + `npx eslint` before declaring done

## Design System (Capstone Paper Palette)
| Token | Hex | Where |
|---|---|---|
| Seller Green | `#1B8A5A` | Household/seller screens |
| Buyer Blue | `#1A85C8` | Collector/buyer screens |
| Canvas | `#F8F9FA` | Backgrounds |
| Pure White | `#FFFFFF` | Cards, inputs |
| Input Grey | `#EDF1F3` | Form fields, inactive tabs |
| Text Primary | `#111827` | Headings, body text |
| Text Secondary | `#6B7280` | Subtitles, metadata |
| Error Red | `#DC2626` | Admin actions, destructive buttons |
| Success Green | `#16A34A` | Verified badges, completed status |
| Star Yellow | `#F59E0B` | Ratings |

- Font: Arial (not Google Fonts)
- No emojis in UI
- No gradients
- Phone mockup size: 390×844 (iPhone 14 Pro)

## Documentation
- Google Docs: Arial 12, justified, 1.5 spacing
- Data dictionary: IT15 CMNetwork (Ursabia) format — FieldName | DataType | Length | Description
- Sheets > Docs for data dictionaries (Docs has rate limits)

## Database (Firebase Firestore — kilotap-prototype)
7 collections matching Capstone Paper 2 spec:
| Collection | Key Fields |
|---|---|
| `sellers` | Seller_ID (PK), Auth_UID, FullName, Email, Phone, Role |
| `collectors` | Collector_ID (PK), Seller_ID (FK), VehicleType, VerificationStatus, AvgRating |
| `bookings` | Booking_ID (PK), Seller_ID (FK), Collector_ID (FK), Status, SpatialAreaRatio |
| `bookingItems` | Item_ID (PK), Booking_ID (FK), MaterialType, ConfidenceScore, EstimatedWeightKg |
| `ratings` | Rating_ID (PK), Booking_ID (FK), Score (1-5), FeedbackText |
| `notifications` | Notification_ID (PK), Recipient_ID (FK), Booking_ID (FK), Title, Message, IsRead |
| `auditLogs` | Log_ID (PK), Admin_ID (FK), Target_ID, ActionType, OldValue, NewValue |

## Git Ignored Files (never commit)
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `.hermes/plans/`

## User
- Kenn Justin Ursabia, Davao City
- 4th yr IT, University of Mindanao
- GitHub: madarax092
- Google: kennuursabia123@gmail.com
- Firebase project: kilotap-prototype
