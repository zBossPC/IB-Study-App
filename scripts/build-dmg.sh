#!/usr/bin/env bash
# Build a properly code-signed IBStudy-macos.dmg (ad-hoc).
# Requires: Xcode toolchain, swift, optional Homebrew `create-dmg`.
set -euo pipefail

# Avoid resource forks / Finder metadata on copies (fixes "resource fork... not allowed" from codesign).
export COPYFILE_DISABLE=1

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="$ROOT/.build/debug"
SPARKLE_FRAMEWORK="$BUILD_DIR/Sparkle.framework"
RESOURCE_BUNDLE="$BUILD_DIR/IBStudy_IBStudy.bundle"
OUT="$ROOT/IBStudy-macos.dmg"
ICON="$ROOT/Sources/IBStudy/Resources/AppIcon.icns"

# Build the .app under /tmp — assembling in ~/Documents can cause Finder/file-provider to
# re-attach com.apple.FinderInfo before the outer codesign (codesign then fails).
TMP_BUILD="$(mktemp -d "${TMPDIR:-/tmp}/ibstudy-app.XXXXXX")"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/ibstudy-dmg.XXXXXX")"
APP="$TMP_BUILD/IBStudy.app"
trap 'rm -rf "$TMP_BUILD" "$STAGE"' EXIT

echo "==> swift build"
swift build

echo "==> Assembling clean app bundle (in temp dir)"
rm -rf "$ROOT/IBStudy.app" 2>/dev/null || true
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"

# -X = do not copy HFS+ extended attributes / Finder flags onto the binary
cp -X "$BUILD_DIR/IBStudy" "$APP/Contents/MacOS/IBStudy" 2>/dev/null || cp "$BUILD_DIR/IBStudy" "$APP/Contents/MacOS/IBStudy"
cp "$ROOT/IBStudy.app.plist" "$APP/Contents/Info.plist" 2>/dev/null \
  || cp "$ROOT/Sources/IBStudy/Info.plist" "$APP/Contents/Info.plist"

# Sparkle framework — ditto avoids resource forks vs cp -R
if [[ -d "$SPARKLE_FRAMEWORK" ]]; then
  mkdir -p "$APP/Contents/Frameworks"
  ditto --norsrc --noextattr --noqtn "$SPARKLE_FRAMEWORK" "$APP/Contents/Frameworks/Sparkle.framework"
fi

# Flat resources only (no .bundle dirs — they break ad-hoc codesign)
cp -fX "$RESOURCE_BUNDLE/unit3.json" "$APP/Contents/Resources/" 2>/dev/null || cp -f "$RESOURCE_BUNDLE/unit3.json" "$APP/Contents/Resources/"
cp -fX "$RESOURCE_BUNDLE/econ_unit4.json" "$APP/Contents/Resources/" 2>/dev/null || cp -f "$RESOURCE_BUNDLE/econ_unit4.json" "$APP/Contents/Resources/"
cp -fX "$RESOURCE_BUNDLE/physics_static.json" "$APP/Contents/Resources/" 2>/dev/null || cp -f "$RESOURCE_BUNDLE/physics_static.json" "$APP/Contents/Resources/"
cp -fX "$RESOURCE_BUNDLE/physics_magnetism.json" "$APP/Contents/Resources/" 2>/dev/null || cp -f "$RESOURCE_BUNDLE/physics_magnetism.json" "$APP/Contents/Resources/"
cp -fX "$RESOURCE_BUNDLE/history_americas_coldwar.json" "$APP/Contents/Resources/" 2>/dev/null || cp -f "$RESOURCE_BUNDLE/history_americas_coldwar.json" "$APP/Contents/Resources/"
cp -fX "$RESOURCE_BUNDLE/MascotGuide.png" "$APP/Contents/Resources/" 2>/dev/null || cp -f "$RESOURCE_BUNDLE/MascotGuide.png" "$APP/Contents/Resources/" 2>/dev/null || true
if [[ -f "$ICON" ]]; then
  cp -fX "$ICON" "$APP/Contents/Resources/AppIcon.icns" 2>/dev/null || cp -f "$ICON" "$APP/Contents/Resources/AppIcon.icns"
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

echo "==> Stripping extended attributes / detritus"
find "$APP" -name '.DS_Store' -delete
# Clear all xattrs (codesign rejects com.apple.FinderInfo, provenance, quarantine, etc.)
xattr -cr "$APP" 2>/dev/null || true

echo "==> Code signing (ad-hoc)"
codesign --force --sign - "$APP/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Downloader.xpc"
codesign --force --sign - "$APP/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc"
codesign --force --sign - "$APP/Contents/Frameworks/Sparkle.framework"
# Finder / file provider may re-attach com.apple.FinderInfo under ~/Documents if we wait; strip again immediately before the outer sign.
xattr -cr "$APP" 2>/dev/null || true
codesign --force --sign - "$APP"
codesign --verify --strict "$APP"
echo "    Signature valid"

ditto --norsrc --noextattr --noqtn "$APP" "$STAGE/IBStudy.app"
find "$STAGE" -name '.DS_Store' -delete
xattr -cr "$STAGE" 2>/dev/null || true

rm -f "$OUT"
rm -f "$ROOT"/rw.*.IBStudy-macos.dmg 2>/dev/null || true

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

touch "$OUT"
ls -lh "$OUT"
echo "Done: $OUT"
