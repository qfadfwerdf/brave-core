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
    // The mobile YouTube site already provides Home, Shorts, subscriptions,
    // search, and video playback UI. Reuse that UI rather than imitate it.
    public static final String START_URL = "https://m.youtube.com/";
    public static final String YOUTUBE_HOST = "youtube.com";
    public static final String MOBILE_YOUTUBE_HOST = "m.youtube.com";

    /**
     * Allow only HTTPS YouTube URLs for dedicated presentation.
     * Avoid matching misleading hosts such as youtube.com.example.org.
     */
    public static boolean isYouTubePage(String url) {
        if (url == null) return false;
        try {
            android.net.Uri parsed = android.net.Uri.parse(url);
            return "https".equalsIgnoreCase(parsed.getScheme())
                    && isYouTubeHost(parsed.getHost());
        } catch (RuntimeException ignored) {
            return false;
        }
    }

    /** Only YouTube pages are eligible for the dedicated app presentation. */
    public static boolean isYouTubeHost(String host) {
        if (host == null) return false;
        String normalized = host.toLowerCase(java.util.Locale.ROOT);
        return normalized.equals(YOUTUBE_HOST)
                || normalized.endsWith("." + YOUTUBE_HOST);
    }

    private TubePlayerLaunch() {}

    public static boolean consumeLaunchRequest(Intent intent) {
        if (intent == null || !intent.getBooleanExtra(EXTRA_ENABLED, false)) {
            return false;
        }
        intent.removeExtra(EXTRA_ENABLED);
        return true;
    }
}
