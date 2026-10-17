#!/usr/bin/env bash
# Execute TubePlayerLaunch's real Java implementation using tiny Android API stubs.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/src/android/content" "$TMP/src/android/net" "$TMP/src/org/chromium/chrome/browser/app"
cp "$ROOT/android/java/org/chromium/chrome/browser/app/TubePlayerLaunch.java" "$TMP/src/org/chromium/chrome/browser/app/"
cat > "$TMP/src/android/content/Intent.java" <<'JAVA'
package android.content;
import java.util.HashMap;
import java.util.Map;
public class Intent {
    private String action;
    private final Map<String, Boolean> extras = new HashMap<>();
    public Intent setAction(String value) { action = value; return this; }
    public String getAction() { return action; }
    public Intent putExtra(String key, boolean value) { extras.put(key, value); return this; }
    public boolean getBooleanExtra(String key, boolean fallback) {
        return extras.getOrDefault(key, fallback);
    }
    public void removeExtra(String key) { extras.remove(key); }
}
JAVA
cat > "$TMP/src/android/net/Uri.java" <<'JAVA'
package android.net;
public class Uri {
    private final java.net.URI delegate;
    private Uri(java.net.URI value) { delegate = value; }
    public static Uri parse(String value) {
        try { return new Uri(new java.net.URI(value)); }
        catch (java.net.URISyntaxException ex) { throw new IllegalArgumentException(ex); }
    }
    public String getScheme() { return delegate.getScheme(); }
    public String getHost() { return delegate.getHost(); }
}
JAVA
cat > "$TMP/src/TubePlayerLaunchTest.java" <<'JAVA'
import android.content.Intent;
import org.chromium.chrome.browser.app.TubePlayerLaunch;
public class TubePlayerLaunchTest {
    private static int count;
    private static void check(boolean condition, String message) {
        count++;
        if (!condition) throw new AssertionError(message);
    }
    public static void main(String[] args) {
        for (String url : new String[]{
            "https://m.youtube.com/", "https://youtube.com/watch?v=1",
            "https://www.youtube.com/shorts/abc", "HTTPS://M.YOUTUBE.COM/"}) {
            check(TubePlayerLaunch.isYouTubePage(url), "Expected allowed: " + url);
        }
        for (String url : new String[]{
            "http://m.youtube.com", "https://youtube.com.evil.org/",
            "https://notyoutube.com", "https://evil.org/youtube.com",
            "https://youtube.com@evil.org/", "javascript:alert(1)",
            "https://youtube.com:bad/", "", "https://youtu.be/a"}) {
            check(!TubePlayerLaunch.isYouTubePage(url), "Expected blocked: " + url);
        }
        check(!TubePlayerLaunch.isYouTubePage(null), "null URL");
        check(!TubePlayerLaunch.isYouTubeHost(null), "null host");
        check(!TubePlayerLaunch.consumeLaunchRequest(null), "null intent");
        Intent ordinary = new Intent().setAction("android.intent.action.MAIN")
            .putExtra(TubePlayerLaunch.EXTRA_ENABLED, true);
        check(!TubePlayerLaunch.consumeLaunchRequest(ordinary), "ordinary intent");
        Intent missing = new Intent().setAction(TubePlayerLaunch.ACTION_OPEN);
        check(!TubePlayerLaunch.consumeLaunchRequest(missing), "missing opt-in");
        Intent dedicated = new Intent().setAction(TubePlayerLaunch.ACTION_OPEN)
            .putExtra(TubePlayerLaunch.EXTRA_ENABLED, true);
        check(TubePlayerLaunch.consumeLaunchRequest(dedicated), "dedicated launch");
        check(!TubePlayerLaunch.consumeLaunchRequest(dedicated), "one-shot consume");
        System.out.println("PASS: " + count + " TubePlayerLaunch Java assertions");
    }
}
JAVA
mkdir -p "$TMP/classes"
javac -d "$TMP/classes" $(find "$TMP/src" -name '*.java')
java -cp "$TMP/classes" TubePlayerLaunchTest
