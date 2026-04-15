#!/usr/bin/env bash
# Build an unsigned IBStudy-macos.dmg for friends (Gatekeeper: right-click → Open).
# Requires: Xcode toolchain, swift, optional Homebrew `create-dmg` for a polished window.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="$ROOT/.build/debug"
APP="$ROOT/IBStudy.app"
OUT="$ROOT/IBStudy-macos.dmg"
ICON="$ROOT/Sources/IBStudy/Resources/AppIcon.icns"

echo "==> swift build"
swift build

echo "==> Sync $APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BUILD_DIR/IBStudy" "$APP/Contents/MacOS/IBStudy"
rm -rf "$APP/Contents/Resources/IBStudy_IBStudy.bundle"
cp -R "$BUILD_DIR/IBStudy_IBStudy.bundle" "$APP/Contents/Resources/IBStudy_IBStudy.bundle"
if [[ -f "$ICON" ]]; then
  cp "$ICON" "$APP/Contents/Resources/AppIcon.icns"
fi

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/ibstudy-dmg.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
cp -R "$APP" "$STAGE/"

if command -v create-dmg >/dev/null 2>&1; then
  echo "==> create-dmg (Finder layout: app + Applications shortcut)"
  VOLICON=()
  if [[ -f "$ICON" ]]; then
    VOLICON=(--volicon "$ICON")
  fi
  # Window: app icon left, Applications drop link right — classic macOS install UX.
  create-dmg \
    --volname "IBStudy" \
    "${VOLICON[@]}" \
    --window-pos 200 120 \
    --window-size 660 420 \
    --icon-size 112 \
    --icon "IBStudy.app" 168 198 \
    --hide-extension "IBStudy.app" \
    --app-drop-link 452 198 \
    --format UDZO \
    "$OUT" \
    "$STAGE"
else
  echo "==> create-dmg not found; using plain hdiutil (install: brew install create-dmg)"
  echo "    Plain DMG still works; drag IBStudy.app to Applications after opening."
  hdiutil create -volname "IBStudy" -srcfolder "$STAGE" -ov -format UDZO -fs HFS+ "$OUT"
fi

touch "$APP"
ls -lh "$OUT"
echo "Done: $OUT"
