#!/usr/bin/env python3
"""Fast source-level checks for the TubePlayer Android prototype.

Run from the brave-core repository root:
    python3 tubeplayer/validate_prototype.py
This is not a substitute for a Chromium Android compile or device test.
"""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "android/java/org/chromium/chrome/browser/app"
MANIFEST = ROOT / "android/java/AndroidManifest.xml"
GN = ROOT / "android/brave_java_sources.gni"
ICON = ROOT / "android/java/res/drawable/tubeplayer_launcher_icon.xml"

def require(condition, message):
    if not condition:
        raise AssertionError(message)

def main():
    launch = (APP / "TubePlayerLaunch.java").read_text()
    require('ACTION_OPEN = "org.brave.tubeplayer.action.OPEN"' in launch,
            "Dedicated TubePlayer action missing")
    launcher = (APP / "TubePlayerLauncherActivity.java").read_text()
    activity = (APP / "BraveActivity.java").read_text()
    sources = GN.read_text()
    manifest = MANIFEST.read_text()
    for filename in ("TubePlayerLaunch.java", "TubePlayerLauncherActivity.java"):
        require(filename in sources, f"Java source not registered: {filename}")
    require("TubePlayerLaunch.ACTION_OPEN" in launcher, "Launcher missing dedicated action")
    require("TubePlayerLaunch.EXTRA_ENABLED, true" in launcher, "Launcher missing activation extra")
    require("ChromeTabbedActivity.class" in launcher, "Launcher not targeting Chromium tabbed Activity")
    require("TubePlayerLaunch.consumeLaunchRequest" in activity, "Activity missing launch handling")
    require("TubePlayerLaunch.isYouTubePage" in activity, "Activity missing YouTube host gate")
    require("setTubePlayerBottomToolbarHidden" in activity, "Bottom controls not wired")
    require("setTubePlayerToolbarHidden" in activity, "Top controls not wired")
    # Brave's AndroidManifest.xml is a fragment inserted into Chromium's manifest.
    # Wrap it in a temporary root for syntax validation.
    # The fragment can reference namespaces supplied by Chromium's outer manifest.
    root = ET.fromstring(
        '<manifest xmlns:android="http://schemas.android.com/apk/res/android" '
        'xmlns:tools="http://schemas.android.com/tools">'
        '<application>' + manifest + '</application></manifest>')
    ns = "{http://schemas.android.com/apk/res/android}"
    matches = [a for a in root.findall(".//activity")
               if a.get(ns + "name") == "org.chromium.chrome.browser.app.TubePlayerLauncherActivity"]
    require(len(matches) == 1, "Exactly one TubePlayer launcher activity required")
    entry = matches[0]
    require(entry.get(ns + "exported") == "true", "Launcher must be exported")
    require(entry.get(ns + "icon") == "@drawable/tubeplayer_launcher_icon", "Icon mismatch")
    require(entry.get(ns + "label") == "TubePlayer", "Label mismatch")
    filters = entry.findall("intent-filter")
    require(any(
        any(a.get(ns + "name") == "android.intent.action.MAIN" for a in f.findall("action"))
        and any(c.get(ns + "name") == "android.intent.category.LAUNCHER" for c in f.findall("category"))
        for f in filters), "Missing launcher intent filter")
    icon = ET.parse(ICON).getroot()
    require(icon.tag == "vector", "Icon is not an Android vector drawable")
    print("PASS: source registration, launcher, manifest, icon, presentation wiring")
    print("NOTE: Android compilation, packaging and ad blocking are NOT verified.")

if __name__ == "__main__":
    try:
        main()
    except (AssertionError, ET.ParseError, OSError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
