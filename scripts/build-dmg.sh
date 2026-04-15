#!/usr/bin/env bash
# Build a properly code-signed IBStudy-macos.dmg (ad-hoc).
# Requires: Xcode toolchain, swift, optional Homebrew `create-dmg`.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="$ROOT/.build/debug"
APP="$ROOT/IBStudy.app"
SPARKLE_FRAMEWORK="$BUILD_DIR/Sparkle.framework"
RESOURCE_BUNDLE="$BUILD_DIR/IBStudy_IBStudy.bundle"
OUT="$ROOT/IBStudy-macos.dmg"
ICON="$ROOT/Sources/IBStudy/Resources/AppIcon.icns"

echo "==> swift build"
swift build

echo "==> Assembling clean app bundle"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"

cp "$BUILD_DIR/IBStudy" "$APP/Contents/MacOS/IBStudy"
cp "$ROOT/IBStudy.app.plist" "$APP/Contents/Info.plist" 2>/dev/null \
  || cp "$ROOT/Sources/IBStudy/Info.plist" "$APP/Contents/Info.plist"

# Sparkle framework
if [[ -d "$SPARKLE_FRAMEWORK" ]]; then
  cp -R "$SPARKLE_FRAMEWORK" "$APP/Contents/Frameworks/Sparkle.framework"
fi

# Flat resources only (no .bundle dirs — they break ad-hoc codesign)
cp -f "$RESOURCE_BUNDLE/unit3.json" "$APP/Contents/Resources/"
cp -f "$RESOURCE_BUNDLE/physics_static.json" "$APP/Contents/Resources/"
cp -f "$RESOURCE_BUNDLE/MascotGuide.png" "$APP/Contents/Resources/" 2>/dev/null || true
if [[ -f "$ICON" ]]; then
  cp "$ICON" "$APP/Contents/Resources/AppIcon.icns"
fi

# Ensure the bundle Info.plist has required keys
/usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string IBStudy" "$APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable IBStudy" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" "$APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :CFBundlePackageType APPL" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :NSPrincipalClass string NSApplication" "$APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :NSPrincipalClass NSApplication" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :NSHighResolutionCapable bool true" "$APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Set :NSHighResolutionCapable true" "$APP/Contents/Info.plist"

echo "==> Stripping extended attributes"
find "$APP" -exec xattr -cr {} + 2>/dev/null || true

echo "==> Code signing (ad-hoc)"
codesign --force --sign - "$APP/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc"
codesign --force --sign - "$APP/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc"
codesign --force --sign - "$APP/Contents/Frameworks/Sparkle.framework"
codesign --force --sign - "$APP"
codesign --verify --strict "$APP"
echo "    Signature valid"

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/ibstudy-dmg.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
cp -R "$APP" "$STAGE/"

if command -v create-dmg >/dev/null 2>&1; then
  echo "==> create-dmg"
  VOLICON=()
  if [[ -f "$ICON" ]]; then
    VOLICON=(--volicon "$ICON")
  fi
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
  echo "==> hdiutil (install create-dmg for a nicer window: brew install create-dmg)"
  hdiutil create -volname "IBStudy" -srcfolder "$STAGE" -ov -format UDZO -fs HFS+ "$OUT"
fi

touch "$APP"
ls -lh "$OUT"
echo "Done: $OUT"
