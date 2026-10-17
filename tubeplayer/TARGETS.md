# TubePlayer Android integration map

Verified against upstream brave/brave-core on 2026-10-17; code not yet compiled.

## Source entry points

- `android/java/org/chromium/chrome/browser/app/BraveActivity.java`: Brave Android main Activity, app lifecycle and launch handling. Investigate startup navigation and onboarding before changing launch behavior.
- `android/java/org/chromium/chrome/browser/toolbar/top/BraveTopToolbarCoordinator.java`: top toolbar coordination; inspect control container and visibility constraints.
- `android/java/org/chromium/chrome/browser/toolbar/bottom/BottomToolbarCoordinator.java`: bottom toolbar coordination; inspect browsing vs tab-switcher modes.
- `docs/patching_and_chromium_src.md`: prefer Brave subclass/override rather than direct Chromium patching for easier upstream rebases.

## Design constraints

1. Gate YouTube-only behavior behind a disabled-by-default feature switch, never globally hide Brave browser controls.
2. Browser control visibility is managed by Chromium/Brave coordinators; do not simply set a View to GONE without testing layout, navigation and fullscreen behavior.
3. Launch routing must preserve sign-in, external URL handling, media playback, back navigation and tab lifecycle.
4. Reusing a pre-installed Brave app does not permit embedding its rendered surface in another Android app.
5. No ad-blocking or Google Play/AdMob compatibility claim until validated by testing and policy review.

## Next engineering action

Trace `BraveActivity` startup navigation and `BraveTopToolbarCoordinator` / bottom toolbar visibility APIs; create a minimal opt-in change only after confirming the correct integration points.
