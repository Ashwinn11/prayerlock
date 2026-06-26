# Prayer Lock — Rebuild Spec

App being reconstructed from ~50 dev-build screenshots (`~/Downloads/IMG_1383..1433`, IMG_1425 missing).
A Christian prayer-lock app: user schedules prayer times; selected apps stay shielded (Screen Time / Family Controls) until the user prays. Whole-Bible KJV included.

## Targets & Identifiers

| Target | Bundle ID | Role |
|---|---|---|
| Main app | `prayer.lock.app` | SwiftUI app + onboarding + main UI |
| DeviceActivityMonitor ext | `prayer.lock.app.monitor` | schedule/threshold callbacks, (un)shield |
| ShieldConfiguration ext | `prayer.lock.app.shield` | custom shield UI on blocked apps |
| ShieldAction ext | `prayer.lock.app.shieldaction` | handle shield button taps |

- App Group: `group.prayer.lock.app` (shared defaults + state between app & extensions)
- Distribution entitlements (Family Controls) already provisioned for all targets.
- Frameworks: FamilyControls, ManagedSettings, DeviceActivity.
- Target device resolution: 1170×2532 (iPhone 390×844pt @3x).

## Design System

- **Background (light screens):** warm cream `~#F0EBE3` / `#EFEAE1`.
- **Background (dark/insight screens):** dark warm brown/charcoal `~#3A352D`.
- **Headline font:** serif (looks like a transitional serif — Georgia/"PT Serif"/"Lora"-ish; likely a custom serif). Large, tight leading.
- **Body/subtitle font:** sans-serif (system / SF Pro), muted gray-brown.
- **Accent color:** gold / amber `~#B5832E`–`#C08A2D` (used for emphasized words: "God", "pray", "PrayerLock", "7 years", "entire Bible").
- **Primary button:** full-width pill, dark charcoal-brown fill, white text ("Continue" / "Get started" / "Let's start"). Disabled = gray fill.
- **On dark screens:** "Continue" appears as plain (borderless) white text near bottom.
- **Back button:** top-left, thin circle outline with chevron `‹`.
- **Progress bar:** thin rounded track, gold fill, sits to the right of the back button (appears once the question section begins).
- **Selection rows:** off-white rounded cards with trailing radio circle (single-select).
- **Slider:** gold fill track, white pill thumb, min/max labels beneath.

## Onboarding Flow (in capture order)

> Light = cream question/insight; Dark = dark insight transition.

1. **IMG_1383** (Light, intro) — Praying-woman illustration (blue hood, yellow top, cross). H: "Social media is taking you away from **God**." Button: **Continue**. (No back btn — first screen.)
2. **IMG_1384** (Light, intro) — Church illustration. H: "**PrayerLock** helps you choose God first, daily." Button: Continue. Back btn appears.
3. **IMG_1385** (Light, intro) — Cross with white shroud in orange circle. H: "Once you **pray**, your apps unlock." Button: **Get started**.
4. **IMG_1386** (Light, input) — Dove+heart illustration. H: "What should we call you?" Sub: "We'll personalize your journey." TextField placeholder "Your name". Button: Continue (disabled until non-empty).
5. **IMG_1387** (Light, intro) — Fist holding rosary illustration. H: "{name} , answer these honestly." (note literal space before comma) Sub: "They help us understand where you are in your walk with God, and personalize your journey closer to Jesus." Button: **Let's start**.
6. **IMG_1388** (Light, Q, progress~5%) — H: "How old are you?" Single-select rows: 14–24 / 25–34 / 35–44 / 45–54 / 55+. Continue disabled until selection.
7. **IMG_1389** (Light, Q, progress) — H: "How long are you on your phone each day?" Sub: "Be honest." Big serif number (e.g. "4") + "hours/day", slider 1–10. Continue.
8. **IMG_1390** (Dark, insight) — 😵‍💫 emoji. "{name} , at this rate you'll spend **{N} years** of your life on your phone." (N computed from hrs/day slider). Continue (plain text).
9. **IMG_1391** (Light, insight) — Holy Bible illustration. "You could read the **entire Bible** in 21 days." Sub: "If you traded screen time for scripture time." Continue.
10. **IMG_1392** (Dark, insight) — Hands holding cross. "The good news: we'll help you give **{N} years back to God**." Continue (plain text).

11. **IMG_1393** (Light, social proof) — Laurel wreath + "THE #1 PRAYER HABIT APP", 5 gold stars. H: "200,000+ Christians are choosing **God** over their screens." Sub: "+20,000 five-star reviews". 3 review cards (5 stars each): (a) "No joke, the only thing that's actually helped me pray consistently. The app lock is genius." — GAME CHANGER; (b) "Finally an app that gets it. I was so sick of my phone owning my mornings. Now God gets the first word." — FINALLY!!; (c) "It really lets me get closer to God. I'm so young and already growing in faith." — Gia Faletto. Button: Continue.
12. **IMG_1394** (Light, Q multi ≤3) — H: "What do you want to **achieve** with PrayerLock?" Sub: "Choose up to 3." Options: Put God first, before my phone / Build a consistent prayer habit / Deepen my relationship with God / Find peace in a chaotic world / Start my day with intention. Continue disabled until ≥1.
13. **IMG_1395** (Light, Q single) — H: "What does a **thriving faith** look like to you?" Options: Trusting God's plan, even when it's hard / Living out my faith with integrity / Using my gifts to serve others / Building my life on the word of God.
14. **IMG_1396** (Light, insight/reflect) — Chalice+host illustration. H: "You're in the **right place**." Sub: "Tens of thousands have started with the same goals — and PrayerLock helped them get there." Two dark cards: **YOUR GOAL** → {one of their 'achieve' picks, e.g. "Deepen my relationship with God"} / "We'll guide you beyond surface-level prayer into a deeper, more intimate conversation with God." and **WHERE YOU'RE HEADED** → {their thriving-faith pick, e.g. "Using my gifts to serve others"} / "92% of people who start here form a daily prayer habit." (DYNAMIC: echoes screens 12 & 13). Button: Continue.
15. **IMG_1397** (Light, Q slider) — H: "How often do you pray per week?" Sub: "Be honest." Big number + "days/week", slider 0–7. Continue.
16. **IMG_1398** (Light, Q single) — H: "How would you describe your **relationship with God** right now?" Options: It has its ups and downs / Feeling a bit distant lately / Just starting or rebuilding / Close and consistent.
17. **IMG_1399** (Light, Q multi ≤3) — H: "What gets in the way of that **thriving faith**?" Sub: "Choose up to 3." Options: Phone & social media distraction / Lack of focus or wandering thoughts / Lack of motivation, feeling dry / Busyness and lack of time / Not knowing what to say.
18. **IMG_1400** (Light, Q multi any) — H: "Sometimes the **real root** runs deeper. Any of these?" Sub: "Choose any that apply." Options: Struggling with lustful thoughts / Constant worry or anxiety / Loneliness or emptiness / Pride or self-reliance / None of these.
19. **IMG_1401** (Light, Q single) — H: "What is your Christian **denomination**?" Sub: "So the prayers and scriptures feel right for you." Options: Non-denominational / Protestant / Catholic / Orthodox / None of the above.
20. **IMG_1402** (Light, Q single) — H: "What's your **sex**?" Sub: "So the prayers and scriptures feel right for you." Options: Man / Woman / Prefer not to say.

### Onboarding, continued (21–40)

21–23. **IMG_1403 / 1404 / 1405** (Light, fake-loading/personalizing) — Top badge "THE #1 PRAYER HABIT APP" + 5 stars. Big progress % (27% → 58% → 91%) with rotating status line: "Preparing your prayer life..." → "Preparing your first conversation with God..." → "Making sure this is tailored to you...". A rotating testimonial card below (e.g. "My relationship with God strengthened. I used to struggle just trying to pray — this app helped me." — Gia Faletto). Auto-advances (no button).
24. **IMG_1406** (Light, how-it-works) — H: "{name}, thank you for your honesty." Sub: "PrayerLock is here to walk with you. Share how you're feeling, pray, and your apps unlock." Numbered 3-step list: ① Share how you're feeling today ② Pray ③ Unlock your apps. Button: **Let's go**.
25. **IMG_1407** (Light, input) — H: "How's your relationship with God today?" Single-line text field (sample "good"). Continue.
26. **IMG_1408** (Light, input) — H: "How are you feeling today?" Text field (sample "good"). Continue. (This pair = the daily "share how you feel" check-in, previewed during onboarding.)
27. **IMG_1409** (Light, guided prayer) — Label "A MOMENT OF PRAYER", title "Let's pray", prayer paragraph, italic scripture ("Be still, and know that I am God..."), ref "PSALMS 46:10". Continue.
28. **IMG_1410** (Light, info) — H: "You can also pray on your own." Sub: "Next time your apps lock, choose a guided prayer or just talk to God in your own words." Continue.
29. **IMG_1411** (Light, verse) — Label "VERSE OF THE DAY", scripture (Micah 6:8), ref "MICAH 6:8". Continue.
30. **IMG_1412** (Light, confirmation) — H: "You completed your first prayer." Journal-entry card: "● Be Still / Jun 26 • just now / {prayer text} / PSALMS 46:10". Note: "Your prayers are saved to your journal to help you build a stronger relationship with God." Continue.
31. **IMG_1413** (Light, companion intro) — H: "Meet your companion." Sub: "As you pray each day, your faith grows. Your companion walks the journey with you." (companion illustration). Continue.
32. **IMG_1414** (Light, input) — H: "Name your companion." Sub: "A gentle reminder to return each day." Text field (sample "Grace"). Button: **Let's go**.
33. **IMG_1415** (Light, community) — H: "Don't walk with God alone." Sub: "PrayerLock helps you pray before you scroll. The community keeps you encouraged, prayed for, and connected." 3 feature rows: **Receive prayer** — "Share what's heavy and let believers pray…"; **See God move** — "Read testimonies, verses, and honest m…"; **Find encouragement** — "A reminder that you're never alone." Continue.
34. **IMG_1416** (Light, setup) — H: "Set your prayer times." Sub: "Your apps lock at these times until you pray." Rows: 8:00 AM / 12:00 PM / 6:00 PM, then "+ Add prayer time". Continue.
35. **IMG_1417** (Light, Q single) — H: "How committed are you to making this happen?" Options: Extremely committed / Very committed / Somewhat committed / A little committed / Just trying it out. Continue.
36. **IMG_1418** (Dark, affirmation) — H: "Your commitment is beautiful." Body: "Your commitment is a gift. And on the days it dips, it's God's grace — not your willpower — that carries you forward." Button: **Done**.
37. **IMG_1419** (Dark, plan) — H: "90 days to build consistency." Card: "90 day prayer journey / 0% complete", with signature line "{name}" + date "Jun 26, 2026". Button: **Start this plan**.
38. **IMG_1420** (Light, commitment/signature) — H: "Make your commitment." Checklist (all checked): ✓ Seek God before my phone ✓ Pray before scrolling ✓ Be intentional with my screen time ✓ Guard my heart and mind. "Sign as a reminder of the promise you're making." (signature pad). Continue.
39. **IMG_1421** (Light, permission primer) — H: "Allow PrayerLock to send notifications." Sub: "We use this so you can unblock your apps when it's time to pray." Mock notification preview: "Your apps are blocked! • now / Time to pray". Buttons: **Allow** / Not now. (triggers system notif prompt)
40. **IMG_1422** (Light, social proof) — Badge "THE #1 PRAYER HABIT APP". H: "Designed for christians like you." "+20,000 five-star reviews" + the 3 review cards (GAME CHANGER / FINALLY!! / Gia Faletto). Button: **Join PrayerLock**.
41. **IMG_1423** (Light, PAYWALL) — H: "From lukewarm to closer to God." Sub: "Give God room to show up in your life." Badge "THE #1 PRAYER HABIT APP / Joined by 500,000+ people". Two plans: **Yearly $39.99 / year** (3-day free trial • $0.77/week) [selected/highlighted] and **Weekly $9.99 / week** (Billed weekly). CTA: **Start my 3-day free trial**. Footer: "No commitment, cancel anytime. Charged after 3 days." + Restore · Terms · Privacy.

> Onboarding likely requests FamilyControls authorization + FamilyActivityPicker somewhere around the prayer-times / blocking setup (a "select apps to block" screen — may be IMG_1425, the one missing screenshot). CONFIRM with user.

## MAIN APP (post-onboarding)

Bottom tab bar (order L→R): **Home · Bible · Journal · Settings** (cream bg, serif/clean labels, active = dark).

### Home — IMG_1424
- Header: "GOOD MORNING" (small caps, muted) / "Grace and peace" (serif greeting; Pauline greeting, not the companion name).
- Big status card: state title **"Unlocked"** (or "Locked"), "Open until your next prayer time", row "Locks again at — 8:00 AM", button **"Pray again"**. (This is the locked/unlocked hero card — uses the two main assets: locked vs unlocked illustration.)
- Stats card (3 cols): **STREAK** 1 · **PRAYERS** 1 · **TO 7 DAYS** 6.
- Companion card: companion illustration + "LEVEL 1", name "Grace", "Faith" progress bar, "Your companion grows as you pray. 6 more to level 2."

### Bible — IMG_1429
- Title "Bible". "VERSE OF THE DAY" card (Micah 6:8).
- "OLD TESTAMENT" section → 2-column grid, each cell = book name (left) + chapter count (right). KJV counts confirmed: Genesis 50, Exodus 40, Leviticus 27, Numbers 36, Deuteronomy 34, Joshua 24, Judges 21, Ruth 4, 1 Samuel 31, 2 Samuel 24, 1 Kings 22, 2 Kings 25, 1 Chronicles 29, 2 Chronicles 36 … (continues; NEW TESTAMENT section below). Tap book → chapters → verses (KJV full text).

### Journal — IMG_1430 / 1431 / 1432
- Title "Journal". "Prayer journey" section with collapsible header ("90 days ⌄" / "Less ^") + "{n}-day streak" + a journey visualization (calendar/heatmap of prayed days).
- List of saved prayer entries as cards: title + "Today • 7:06 AM", "+" to add. Each entry → detail (IMG_1432): title "Draw Me Near", timestamp "Jun 26, 2026 at 7:06 AM", prayer text, italic scripture + ref (JAMES 4:8), "YOUR REFLECTION" text area ("Write a thought, a thanks, or a hope…"), **Save**.

### Settings — IMG_1433
- **BLOCKING**: "Blocked apps" → "{n} selected ›" (opens FamilyActivityPicker).
- **PRAYER TIMES**: "Apps lock at these times until you pray." list of times + "+ Add prayer time".
- **REMINDERS**: "Daily reminder" toggle + "Time 8:00 AM".
- **ABOUT**: Privacy Policy › / Terms of Use / Version v1.0.
- **DATA**: "Delete all data".

### Prayer session flow (the core loop) — IMG_1406-style entry → IMG_1407/1408 → IMG_1426 → IMG_1427 → IMG_1428
1. Trigger: prayer time hits → apps shield; user opens app (via notif / "Pray again").
2. Check-in: "How are you feeling today?" / "How's your relationship with God today?" (free text) → selects an appropriate guided prayer.
3. **Guided prayer player (IMG_1426)**: label "A MOMENT OF PRAYER", countdown timer (e.g. 0:58), breathing cue "BREATHE", prayer title ("Thirsty For You"), prayer body, italic scripture + ref (PSALMS 42:1), footer "Be still • 0:58". (timed, calming).
4. Reflection (IMG_1427): "Sit with it" — "Write a thought, a thanks, or a hope. Optional." → **Save & unlock** / Skip.
5. Done (IMG_1428): "Amen." "Your apps are unlocked for the rest of today. Carry the quiet with you." → **Done**. (shield cleared until next prayer time / rest of day.)

Guided-prayer library (seen): "Be Still" (Psalms 46:10), "Thirsty For You" (Psalms 42:1), "Draw Me Near" (James 4:8). Need a fuller set keyed to moods/feelings.

## Screen Time / Family Controls architecture
- **Main app**: requests `AuthorizationCenter.shared.requestAuthorization(for: .individual)`. Presents `FamilyActivityPicker` → stores `FamilyActivitySelection` (encoded) in App Group. Schedules `DeviceActivitySchedule`s (one per prayer time → end of day) via `DeviceActivityCenter().startMonitoring(...)`. On prayer completion, clears shield (`ManagedSettingsStore().shield.applications = nil`) and records "unlocked until next prayer time".
- **monitor ext (`prayer.lock.app.monitor`)**: `DeviceActivityMonitor` — `intervalDidStart` → set `store.shield.applications = selection.applicationTokens` (lock). Reads selection/state from App Group.
- **shield ext (`prayer.lock.app.shield`)**: `ShieldConfigurationDataSource` — custom shield: app icon, title "Time to pray", subtitle, primary button "Open PrayerLock", optional secondary.
- **shieldaction ext (`prayer.lock.app.shieldaction`)**: `ShieldActionDelegate` — handle button taps (note iOS limitation: cannot directly launch containing app from shield action; rely on notification deep-link / user opening app).

## Open questions / to confirm with user
- IMG_1425 (missing) — likely the FamilyActivityPicker / "select apps to block" + Screen Time permission screen. Confirm copy.
- KJV text source (drop-in JSON/SQLite vs I source public-domain KJV).
- Companion: how many levels / art per level? (asset needs)
- Paywall: StoreKit 2 product IDs? RevenueCat? Or stub for now.
- Exact accent (gold) words on OCR-only screens — inferred from the established pattern (the key concept word).

## Dynamic behavior observed
- Name captured at screen 4 is injected into later screens (`{name} ,` with leading space before comma).
- Phone hours/day slider → computes a "years of your life" figure (4 hrs/day → "7 years") shown on later screens and echoed in "give N years back to God".
- Progress bar advances through the question section.
- Light vs dark screens alternate to create emotional rhythm; dark screens use plain-text Continue.

## TODO: still to view
IMG_1393–1433 (main onboarding remainder + main app screens). Bible reader, prayer scheduling, app-picker (FamilyActivityPicker), shield screens, home/dashboard.
