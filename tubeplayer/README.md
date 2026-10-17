# TubePlayer prototype

Goal: evaluate a YouTube-focused Android experience built on Brave without replacing Brave's ad-blocking implementation.

## Initial requirements
- Launch the mobile YouTube website on app startup.
- Explore hiding browser chrome (address bar, tabs, menus) only in the dedicated experience.
- Preserve back navigation, sign-in, video playback, and fullscreen playback.
- Do not claim ad blocking is verified until testing on an actual Android build.
- Keep modifications isolated from upstream Brave wherever possible.

## Validation gates
1. Identify Android startup Activity and navigation routing.
2. Identify top/bottom toolbar visibility controls and constraints.
3. Implement behind an opt-in feature flag, preserving standard Brave behavior.
4. Build a signed-for-testing APK in a suitably provisioned environment.
5. Test YouTube playback, sign-in, fullscreen, navigation, and ad behavior on device.
6. Before any public release, review Brave/Chromium licenses, branding, YouTube terms, and Google Play policy. Do not assume store approval.

No application functionality has been implemented by this document.
