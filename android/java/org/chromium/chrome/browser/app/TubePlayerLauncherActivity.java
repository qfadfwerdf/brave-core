/* Copyright (c) 2026 TubePlayer contributors.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at https://mozilla.org/MPL/2.0/. */
package org.chromium.chrome.browser.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import org.chromium.chrome.browser.ChromeTabbedActivity;

/**
 * Lightweight launcher entry point. It forwards into the real Chromium/Brave
 * tabbed Activity rather than opening an external browser or a WebView.
 */
public final class TubePlayerLauncherActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = new Intent(this, ChromeTabbedActivity.class);
        // Use a dedicated action so Chromium does not treat this as an
        // ordinary Brave launcher intent during startup.
        intent.setAction("org.brave.tubeplayer.action.OPEN");
        intent.putExtra(TubePlayerLaunch.EXTRA_ENABLED, true);
        // Reuse the existing tabbed Activity when present, but do not clear
        // the entire task stack (which could discard unrelated Brave UI).
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);
        finish();
    }
}
