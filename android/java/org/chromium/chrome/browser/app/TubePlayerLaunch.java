/* Copyright (c) 2026 TubePlayer contributors.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at https://mozilla.org/MPL/2.0/. */
package org.chromium.chrome.browser.app;

import android.content.Intent;

/**
 * Experimental TubePlayer launch contract.
 *
 * This is deliberately opt-in. A regular Brave launch must not change behavior.
 * The flag is consumed once so an Activity resume does not repeatedly redirect.
 */
public final class TubePlayerLaunch {
    public static final String EXTRA_ENABLED = "org.brave.tubeplayer.ENABLED";
    public static final String START_URL = "https://m.youtube.com/";

    private TubePlayerLaunch() {}

    public static boolean consumeLaunchRequest(Intent intent) {
        if (intent == null || !intent.getBooleanExtra(EXTRA_ENABLED, false)) {
            return false;
        }
        intent.removeExtra(EXTRA_ENABLED);
        return true;
    }
}
