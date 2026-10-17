#!/usr/bin/env bash
# Run from a fully provisioned Linux Brave/Chromium build environment.
# This script does not download Android SDKs or install system dependencies.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f package.json ]]; then
  echo "ERROR: Run this script from the brave-core checkout." >&2
  exit 1
fi
python3 tubeplayer/validate_prototype.py

# Preflight should work without Node or pnpm; require those only when
# explicitly starting the heavyweight Chromium/Brave build.
if [[ "${TUBEPLAYER_CONFIRM_BUILD:-}" == "yes" ]] && ! command -v pnpm >/dev/null 2>&1; then
  echo "ERROR: pnpm is required to build; see Brave Android development instructions." >&2
  exit 1
fi

ARCH="${TUBEPLAYER_ARCH:-arm64}"
case "$ARCH" in
  arm|arm64|x86|x64) ;;
  *) echo "ERROR: Unsupported TUBEPLAYER_ARCH=$ARCH" >&2; exit 1 ;;
esac

if [[ "${TUBEPLAYER_CONFIRM_BUILD:-}" != "yes" ]]; then
  echo "Preflight passed. No build started."
  echo "To download Chromium and build Android (substantial disk/RAM/time required):"
  echo "  TUBEPLAYER_CONFIRM_BUILD=yes TUBEPLAYER_ARCH=$ARCH bash tubeplayer/build_android.sh"
  exit 0
fi

echo "Initializing Chromium/Brave Android build for $ARCH"
pnpm run init --target_os=android --target_arch="$ARCH"
echo "Building Chromium/Brave Android for $ARCH"
pnpm run build --target_os=android --target_arch="$ARCH"
echo "Build command finished. Locate and verify the generated APK before installing."
echo "This is still a Brave-based prototype, not a separately packaged TubePlayer app."
