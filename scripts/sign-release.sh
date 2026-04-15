#!/usr/bin/env bash
# Sign IBStudy-macos.dmg for Sparkle (EdDSA). Uses the private key from `generate_keys`
# that pairs with SUPublicEDKey in Info.plist. Optional: SPARKLE_PRIVATE_KEY=/path/to/key.pem
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DMG="${1:-$ROOT/IBStudy-macos.dmg}"

if [[ ! -f "$DMG" ]]; then
  echo "Usage: $0 [path/to/IBStudy-macos.dmg]" >&2
  exit 1
fi

SIGN_BIN="${SIGN_UPDATE_BIN:-}"
if [[ -z "$SIGN_BIN" ]]; then
  SIGN_BIN="$(ls /opt/homebrew/Caskroom/sparkle/*/bin/sign_update 2>/dev/null | head -1 || true)"
fi
if [[ -z "$SIGN_BIN" || ! -x "$SIGN_BIN" ]]; then
  echo "Install: brew install --cask sparkle  (provides bin/sign_update)" >&2
  exit 1
fi

if [[ -n "${SPARKLE_PRIVATE_KEY:-}" && -f "${SPARKLE_PRIVATE_KEY}" ]]; then
  exec "$SIGN_BIN" "$DMG" -f "${SPARKLE_PRIVATE_KEY}"
fi
exec "$SIGN_BIN" "$DMG"
