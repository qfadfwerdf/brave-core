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
        intent.setAction(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_LAUNCHER);
        intent.putExtra(TubePlayerLaunch.EXTRA_ENABLED, true);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);
        finish();
    }
}
