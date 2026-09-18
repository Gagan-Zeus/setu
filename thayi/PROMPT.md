# Claude Code prompt — Setu Thayi (mother app)

Paste everything in the fenced block below into Claude Code as your first message.
Save a copy in the repo as `thayi/PROMPT.md` so you can re-feed it if a session loses context.

---

```
Build a Flutter mobile app called "Setu Thayi" that runs on BOTH Android and iOS
from a single codebase. It is the mother-facing app of Setu, a maternal health
platform for rural Karnataka, India. It is a digital version of the government
paper "Thayi Card" that pregnant women carry.

=== WHO USES THIS ===
A pregnant woman in a village. She may have limited literacy, is not comfortable
in English, and shares a low-end Android phone with her family. Design every
screen for her:
- Kannada is the DEFAULT language. English is a toggle, not the other way round.
- Large touch targets, minimum 56dp height on anything tappable.
- Icon plus text on every action, never icon alone.
- One idea per screen. Short sentences. No medical jargon.
- Body text 18sp minimum, headings 24sp+.
- High contrast. Assume bright sunlight and a scratched screen.
She only READS her health record. She never edits clinical data — her ASHA worker
and her PHC doctor write it.

=== TECH REQUIREMENTS ===
- Flutter, latest stable, null safety, Material 3.
- Single codebase targeting Android (minSdk 23) and iOS (13.0+).
- State management: Riverpod.
- Localisation: flutter_localizations + ARB files. Create lib/l10n/app_kn.arb and
  lib/l10n/app_en.arb. EVERY user-facing string goes through the ARB files — do not
  hardcode any display text in widgets. Kannada is the default locale.
- Font: Noto Sans Kannada via google_fonts, so Kannada glyphs render correctly on
  both platforms.
- DATA LAYER: do NOT connect to a real backend yet. Define an abstract
  `MotherRepository` interface and provide a `MockMotherRepository` that returns
  realistic hardcoded data with a short artificial delay. A Supabase implementation
  will be swapped in later behind the same interface. Keep all mock data in one
  file, lib/data/mock_data.dart, so it is easy to edit for a demo.
- Persist the language choice and a fake auth token with shared_preferences.
- Packages to use: flutter_riverpod, google_fonts, qr_flutter, url_launcher,
  intl, shared_preferences, speech_to_text, permission_handler.

=== NAVIGATION ===
App opens on Splash → Login. After successful login, Home is the root and cannot
be popped back to Login. All other screens push from Home.

A floating red EMERGENCY button must be visible on EVERY screen after login,
anchored bottom-right, above all content. It opens the Emergency screen from
anywhere. Implement it once as a wrapper/scaffold, not repeated per screen.

=== SCREENS ===

1. SPLASH
   Logo, app name in Kannada, brief load.

2. LOGIN
   - Enter phone number (10 digits, Indian format).
   - OTP code entry, 6 boxes. Accept any 6 digits as valid in mock mode.
   - Language selector: ಕನ್ನಡ / English, prominent, works before login.
   - A short data consent notice: what is collected, who can see it, that she can
     withdraw consent. She must tap to accept before continuing. Store the
     acceptance timestamp locally.

3. HOME
   Vertical cards, in this order:
   - Header: her name and a greeting in Kannada.
   - "Weeks pregnant": large number, e.g. "32 ವಾರ", with a slim progress bar
     across 40 weeks.
   - "Expected delivery date": formatted date, plus days remaining.
   - "Next checkup": date, location, and an amber warning state if overdue.
   - "Ask Setu": entry card into the AI chat, phrased as an invitation to ask
     anything about pregnancy.
   - A bottom navigation bar or grid of large icon buttons leading to: My Thayi
     Card, My Checkups, My Health, My Schemes.
   - The floating emergency button.

4. MY THAYI CARD
   - Large QR code (qr_flutter) encoding a URL of the form
     setu://m/<uuid>?t=<token>. IMPORTANT: never encode her name, phone, or any
     personal data in the QR itself — only the id and token.
   - Caption in Kannada: show this at the hospital.
   - Below the QR: name, age, husband/guardian, village, blood group, EDD,
     Thayi card number, her ASHA worker's name.
   - A "works offline" indicator — this screen must render from cache with no
     network.

5. MY CHECKUPS
   Two tabs or two sections:
   - Upcoming: date, which visit number, what will be done, location.
   - Completed: date, weight, BP, and who recorded it.
   - Any overdue visit appears at the top in amber with a "contact your ASHA"
     button.

6. MY HEALTH
   Read-only summary cards:
   - Blood group and high-risk flags (render risk flags as coloured chips).
   - Weight history: simple line chart across visits.
   - Blood pressure history: line chart, systolic and diastolic.
   - Tablet reminders: iron (IFA) and calcium, with a simple taken/not-taken
     tracker for today.
   - TT vaccination doses: which given, which due.
   Charts should be simple and readable — draw with CustomPainter or fl_chart,
   not a heavy dashboard library.

7. MY SCHEMES
   A list of Karnataka and central maternity schemes: Thayi Bhagya, PMMVY, JSY,
   Prasooti Araike, Madilu Kit, JSSK. For each:
   - Scheme name.
   - Eligible / not eligible badge, based on mock profile fields (BPL status,
     district, delivery number, place of delivery).
   - What she receives, described in plain Kannada.
   - Documents she must carry, as a checklist.
   - Nearby empanelled hospitals.
   Add a permanent footnote: amounts and eligibility are indicative — confirm with
   your ASHA worker or PHC. Do NOT display specific rupee amounts as guaranteed.

8. ASK SETU (AI chat)
   - Chat interface, messages in Kannada.
   - Text input plus a microphone button using speech_to_text with the Kannada
     locale. Request microphone permission with a clear rationale.
   - Above the input, a row of tappable "common question" chips grouped by topic:
     Food, Rest and work, After delivery. Tapping a chip sends that question.
     This is essential for low-literacy users who cannot type.
   - Stub the AI call behind an abstract `ChatService` with a `MockChatService`
     that returns canned Kannada answers. A real API call will be swapped in.
   - CRITICAL SAFETY BEHAVIOUR, implement this in the client, not the model:
     Before any message is sent to the chat service, run it through a
     `DangerSignDetector` — a hard-coded keyword matcher covering bleeding,
     severe headache, blurred vision, reduced or absent fetal movement, fever,
     swelling of face or hands, and convulsions, in both Kannada and English.
     If it matches, DO NOT send the message. Immediately show a full-screen
     interrupt telling her this needs attention now, with call buttons for her
     ASHA worker and the PHC. This must fire every time, deterministically.
   - A "Contact my ASHA" action that appears when the assistant cannot answer,
     which composes her question as a message to her ASHA worker.
   - A permanent line beneath the input: "ಸಲಹೆ ಮಾತ್ರ — ವೈದ್ಯರ ಸಲಹೆಯಲ್ಲ"
     (advice only, not a doctor's opinion).

9. DANGER SIGNS
   Warning signs during pregnancy, each as a card with a large icon, a plain
   Kannada description, and what to do. Include: bleeding, severe headache,
   blurred vision, swelling of face and hands, fever, convulsions, reduced fetal
   movement. Each card has a "call my ASHA" action.

10. MY ASHA WORKER
    Her ASHA worker's name, photo placeholder, sub-centre, and phone number, with
    a large call button.

11. EMERGENCY
    Reachable from every screen. Must render instantly and work offline.
    - Blood group, high-risk flags, EDD, allergies — large text, readable by
      someone else holding her phone.
    - Three big call buttons: Call ASHA, Call PHC, Call 108 ambulance
      (use url_launcher with tel: URIs).
    - Nearest empanelled hospital with name, distance, and a directions button.

12. AFTER DELIVERY
    - Baby immunisation schedule: vaccine, due age, given/pending status.
    - Baby growth records: weight entries over time, simple chart.

=== PLATFORM CONFIGURATION ===
Configure both platforms properly, do not leave defaults:

ANDROID (android/app/src/main/AndroidManifest.xml, build.gradle):
- applicationId: com.setu.thayi
- App label from string resources so it can be localised.
- Permissions: INTERNET, RECORD_AUDIO (voice input), CALL_PHONE is NOT needed —
  use ACTION_DIAL via url_launcher so no permission is required.
- minSdk 23, targetSdk current.

iOS (ios/Runner/Info.plist):
- Bundle identifier: com.setu.thayi
- NSMicrophoneUsageDescription and NSSpeechRecognitionUsageDescription with clear
  user-facing reasons for voice input.
- LSApplicationQueriesSchemes including "tel" so call buttons work.
- CFBundleLocalizations including "kn" and "en".
- Deployment target 13.0.

Do NOT add camera permissions. This app displays a QR code, it never scans one.

=== BUILD ORDER ===
Build in this sequence and make each step run before moving on:
1. Project scaffold, theme, Riverpod setup, ARB localisation with Kannada default.
2. Mock data layer and repository interface.
3. Login and consent flow.
4. Home.
5. My Thayi Card with the QR.
6. Emergency plus the global floating button.
7. Ask Setu, including the DangerSignDetector before the chat UI.
8. My Schemes.
9. My Checkups, My Health.
10. Danger Signs, My ASHA Worker, After Delivery.

Steps 3 to 7 are the demo. If time is short, everything after step 7 can remain a
placeholder screen.

=== DESIGN DIRECTION ===
Deep teal-green as the primary colour, warm terracotta as the accent, warm
off-white background. Rounded cards with soft shadows. Generous spacing. It should
feel calm and trustworthy, like a health service — not like a consumer app.
Emergency elements are the only place red appears.

=== WHAT NOT TO DO ===
- Do not hardcode display strings outside the ARB files.
- Do not put personal data in the QR payload.
- Do not let the AI chat answer anything about medicines or dosages.
- Do not rely on the chat model to catch danger signs — the keyword detector is
  the safety mechanism.
- Do not add a backend, auth provider, or analytics yet.

Start with step 1. After each step, tell me what you built and what to check
before you continue.
```

---

## After it scaffolds

**Put a short version in `thayi/CLAUDE.md`** so every future session picks it up automatically:

```markdown
# Setu Thayi
Flutter app for pregnant women in rural Karnataka. Android + iOS.
Kannada is the default language — all strings live in lib/l10n/*.arb, never inline.
She reads her record, never edits it.
Data comes from MockMotherRepository behind the MotherRepository interface.
Supabase will be swapped in later — do not couple UI to any backend.
Safety: DangerSignDetector runs client-side before any chat message is sent.
It is a hard-coded keyword matcher, not a model call, and must fire every time.
Never put personal data in the QR payload.
```

## Building for iOS

Android builds anywhere. iOS needs macOS with Xcode, or a cloud builder —
**Codemagic** works and you have used it before. Set it up early rather than at
hour 22, since provisioning profiles are where iOS builds usually stall.

For the demo itself, Android is enough. Have the iOS build as proof it's
cross-platform, not as the device you present from.

## Two notes on your sitemap

**Login still sits as a child of Home** on the Octopus map. The prompt routes it
correctly regardless — Login is the entry point, Home is the post-auth root — but
fix it on the map before it goes in a slide, or it reads backwards.

**"Learn more about your pregnancy" became Ask Setu** in this prompt. That block
was too vague to build from, and making it the chat entry point gives Home a
purpose it didn't have.
