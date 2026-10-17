# TubePlayer Android build and verification

## Current deliverable

The prototype is **not** a standalone Android application. It adds a second
launcher entry to a Brave Android package, then opens the existing Chromium
tabbed activity with TubePlayer presentation enabled. Brave Shields is reused
from the host browser; neither YouTube ad blocking nor video playback has
been verified on a device.

The fork `qfadfwerdf/brave-browser` is an issues/wiki repository, **not**
the build entry point. Source changes live on the `tubeplayer/prototype`
branch of `qfadfwerdf/brave-core`.

## Lightweight validation (no Chromium checkout needed)

From the root of the brave-core checkout:

```bash
python3 tubeplayer/validate_prototype.py
bash tubeplayer/test_launch_contract.sh
bash -n tubeplayer/build_android.sh
bash tubeplayer/build_android.sh
```

The Java contract test requires a JDK (`javac` and `java`). It compiles
the actual `TubePlayerLaunch.java` against minimal Android API stubs.
It does not compile Chromium or run Android instrumentation tests.

## Real Android build (Linux)

Follow the upstream Brave Android environment prerequisites:
https://github.com/brave/brave-browser/wiki/Android-Development-Environment

The upstream brave-core README documents the checkout structure:
`<project>/src/brave`. In a full build workspace, check out the fork and
switch to the feature branch:

```bash
mkdir -p ~/tubeplayer-build/src
git clone https://github.com/qfadfwerdf/brave-core.git ~/tubeplayer-build/src/brave
cd ~/tubeplayer-build/src/brave
git switch tubeplayer/prototype
```

Install the prerequisite packages and pnpm as instructed upstream, then run:

```bash
TUBEPLAYER_CONFIRM_BUILD=yes TUBEPLAYER_ARCH=arm64 bash tubeplayer/build_android.sh
```

This runs the upstream documented commands:

```bash
pnpm run init --target_os=android --target_arch=arm64
pnpm run build --target_os=android --target_arch=arm64
```

**Important:** Chromium fetch and compilation need substantial storage, RAM,
network bandwidth, and time. Do not attempt on a resource-constrained CI
runner without a suitable build cache or dedicated build machine.

The script does **not** locate, sign, or publish an APK. After a successful
build, locate the APK in the build output, inspect its package ID, sign it
with a testing key if needed, and install it on a test device. Do not assume
the upstream output is a separate TubePlayer package.

## Device acceptance checklist

1. Confirm the APK installs and a TubePlayer launcher icon appears.
2. Launch TubePlayer and verify `https://m.youtube.com/` opens internally,
   without handing off to the external Brave app or Android WebView.
3. Check Home, Search, Shorts, Subscriptions, watch pages, Back, and rotation.
4. Verify login persistence, fullscreen playback, picture-in-picture, and
   navigation to external sites.
5. Verify that browser toolbars disappear only on eligible HTTPS YouTube
   pages and return on other pages and normal Brave launches.
6. Test Brave Shields on a real device with repeatable test cases; distinguish
   website ads, in-video ads, and legitimate video playback failures.
7. Test process death, app relaunch, deep links, and Android task switching.

## Independent APK blockers

A separately installable TubePlayer app still needs a **different application
ID/package configuration**, product-specific name/icon/resources, isolated
profile and task behavior, and an independent signed output. The extra launcher
activity currently shares the Brave package and profile; it is **not**
app isolation. Changing only the manifest label or launcher icon does not
create a standalone APK.

Before distribution, review licensing, trademark usage, YouTube terms,
and app-store policy.
