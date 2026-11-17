# UI cleanup review

Date: 3 October 2026

Scope: home, education catalog and banner fallback, selfcare landing, profile, login, registration, shared theme and shared loading/empty/error presentation.

Design read: a university health education app for students, using the existing navy/ocean blue/cyan identity. ENERGY 2 / RHYTHM 2 / MOTION 1, from `DESIGN.md`.

## Decisions and purpose

- Home leads with the current learning module so the next useful action is visible before secondary services.
- Module progress uses a sentence, percentage and bar rather than three separate boxes; each conveys completion or progress without extra surfaces.
- Account points and active days live in profile, where they belong to the account summary.
- The home notification control was removed because its message was a static readiness claim without notification data.
- The "Wawasan & Aktivitas" section and its two home shortcuts were removed at the user's request.
- Services and reading guides use divided rows because they are destinations, not independent dashboard metrics.
- The education catalog uses numbered, wrapping titles; optional API banners appear only where there is space to read them.
- Selfcare groups cycle tracking and IMT in the existing measurement component, while supporting guides stay visually lighter.
- Profile keeps an initial avatar and real account fields, with explicit missing-data labels and stacked academic values.
- Login and registration use the page surface to give fields room and preserve native radio feedback.
- The login redesign uses a compact identity header on phones and a separate navy identity panel on wide screens. The existing SIKERA logo and educational tagline connect the page to the student health product.
- Login labels stay above the fields so they remain visible after typing; stronger field borders distinguish the input areas in both themes.
- The login form is the primary task: one full-width submit button, followed by the existing student registration action. The form reflows to one column when text is enlarged.
- Login errors appear beside the form and clear when editing. Autofill, next/done keyboard actions and the password visibility control support entering credentials.
- Navy headings provide identity; blue/cyan are reserved for actions, selections and progress. Container colors now come from the same palette.
- Roboto and platform fallback follow the existing reading-focused direction; shared button and app-bar styles specify the same family.
- Whitespace separates tasks and sections; rounded surfaces group an active lesson or related measurements, rather than every item.
- Material controls supply interaction and focus feedback; no decorative animation was added.

## Validation

- `flutter analyze --no-pub`: no issues.
- Full `flutter test --no-pub --reporter expanded`, with home, education and secondary screenshot flags: 159 tests passed.
- `flutter build web --no-pub`: release compilation verified.
- Follow-up removal of "Wawasan & Aktivitas": 19 home tests passed, analyzer clean, and refreshed light/dark captures reviewed.
- Follow-up login redesign: 30 auth/legal tests passed with `SIKERA_CAPTURE_LOGIN=1`; analyzer and release web build passed. The empty login form was reviewed at 390 x 844px and 1280 x 900px in both themes, using the existing logo and a locally loaded font. Login also passes 320px with 200% text, an inline error/recovery state and a 320px keyboard inset.
- Screenshot review covered home, education, selfcare and profile in light and dark themes. Captures use clearly identified test fixtures and a locally loaded font for visual review.
- Home fits 320, 360, 390, 720 and 1280px in both themes. Home, education, selfcare, profile and auth also pass narrow layouts with 200% text.
- Shared recovery states pass at 320 x 180px with 200% text, including scrolling to and activating retry.
- Color-scheme text pairs and light muted text pass calculated 4.5:1 contrast assertions. Cyan uses navy text; dark errors use a lighter presentation color.

These checks exercise widgets, controllers with test fixtures, route callbacks and compilation. Live production sign-in and server responses were not exercised.

## Recorded interactions

- Home search filters modules, opens the matching ID, handles no matches and clears the query.
- Previous/next module controls change the selected module; start/continue and read-again actions open that module.
- All-modules opens the catalog; returning refreshes dashboard data.
- Home education, counseling and profile shortcuts select their existing tabs.
- Home period, trivia and selfcare shortcuts retain their routes.
- Education module rows open the correct ID and refresh after returning.
- Selfcare record, history and simulation actions pass their existing period route arguments.
- IMT and both reading guides navigate; the guide controls also trigger their existing data loads.
- Profile theme switches both ways; both legal links navigate; logout cancel and confirm behave correctly.
- Auth password controls toggle visibility; registration navigation and gender selection work.
- Auth loading indicators remain readable and announce the action in both themes.
- Login input labels have accessibility semantics; inline errors are announced as a live region.
- Login submit remains reachable above a 320px keyboard inset in the phone layout.
- Password keyboard Done submits once; the live loading guard prevents a repeated submission. While processing, fields are read-only and the submit button is disabled.
- Empty, loading, error, retry, pull-to-refresh and completed learning states are exercised.
- Home profile action works with Tab and Enter; existing assessment and reading keyboard checks also pass.

## Anti Slop delivery gate

Each PASS below applies to the revised surfaces in this patch, with the validation limits above.

- R-01 PASS: existing brand colors retained; decorative landing gradients removed.
- R-02 PASS: revised product text uses ordinary punctuation without em dashes.
- R-03 PASS: narrow and enlarged-text widget checks report no overflow; native control targets retained.
- R-04 PASS: service icons represent books, discussion, calendar, quizzes and health tools; decorative metric glyphs removed.
- R-05 PASS: active lesson, catalog, measurements, reading rows and forms follow their content tasks.
- R-06 PASS: shared sans typography supports readable student health content, per the existing design direction.
- R-07 PASS: no decorative background grid or pattern added.
- R-08 PASS: chevrons indicate module selection or guide navigation; decorative CTA arrows removed.
- R-09 PASS: neutral module statuses are text; decorative account badges removed.
- R-10 PASS: no glass or blur used on the revised surfaces.
- R-11 PASS: existing radius tokens retained for grouped surfaces and controls; form cards removed.
- R-12 PASS: landing/profile shadows removed; hierarchy comes from content and spacing.
- R-13 PASS: no glow treatment added.
- R-14 PASS: services are rows, learning is one active surface, and measurements use their existing grouping.
- R-15 PASS: start, continue, read again, record, calculate and retry actions name their purpose.
- R-16 PASS: revised copy describes available actions without promotional buzzwords.
- R-17 PASS: displayed progress and account values come from their existing models.
- R-18 PASS: no testimonial or fictional person added.
- R-19 PASS: only native control feedback and existing navigation behavior retained.
- R-20 PASS: navy headings, blue/cyan actions and numbered learning content preserve SIKERA identity.
- R-21 PASS: existing user-selected light/dark behavior retained and exercised.
- R-22 PASS: no new illustration; API banners remain supporting content where space allows.
- R-23 PASS: no invented logo/photo/navigation asset; account initials remain an honest marker.
- R-24 PASS: existing destination callbacks verified by route and tab assertions.
- R-25 PASS: shared foreground/background pairs pass contrast calculations; empty-learning and disabled-loading colors corrected.
- R-26 PASS: revised controls retain real callbacks, with the interaction results recorded above.
- R-27 PASS: loading labels, missing data, errors and retry are exercised in both themes.
- R-28 PASS: no FAQ added.
- R-29 PASS: existing navy/ocean/cyan brand palette and necessary status colors retained.
- R-30 PASS: composition follows SIKERA learning and tracking tasks; no external product template used.
- R-31 PASS: major color, layout, typography, spacing, grouping and icon decisions have reasons above.
- R-32 PASS: native keyboard/focus handling retained; home Tab/Enter and existing keyboard tests pass.
- R-33 PASS: UI changes were written in the Dart sources; no runtime patching script added.
- R-34 PASS: both themes pass layout/state checks and were reviewed as rendered captures.
- R-35 PASS: full widget suite and release web build run; interactions and screenshots recorded above.
- R-36 PASS: static notification claim and fake email fallback removed; no new trust or medical claim added.
- R-37 PASS: `DESIGN.md` loaded before implementation; its 2/2/1 dials retained.
- R-38 PASS: missing account information is labeled; screenshots use documented test data.
- Liveliness PASS: the active lesson is the home focal point; task headings and spacing define rhythm; cyan highlights that lesson. Login uses the existing illustrated SIKERA logo and navy identity panel, with the form as its action focus.
- C-1 PASS: decisions are connected to student tasks and the existing identity.
- C-2 PASS: tested navigation, state controls and recovery actions function.
- C-3 PASS: secondary destinations and account metrics no longer compete with the learning task.
- C-4 PASS: theme, width, text-scale and state checks pass within the recorded scope.
- C-5 PASS: no evidence, statistic or testimonial invented for the cleanup.
