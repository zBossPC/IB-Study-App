#!/usr/bin/env bash
# One-shot release: bump version + build + Sparkle appcast + git + GitHub release.
#
# Usage:
#   ./scripts/release.sh 1.0.7
#   ./scripts/release.sh --dry-run 1.0.7          # print steps only
#   ./scripts/release.sh --no-git 1.0.7           # bump files, DMG, appcast; skip commit/push/gh
#
# Requires: Xcode/swift, create-dmg (optional), Sparkle sign_update (brew install --cask sparkle),
#           gh (brew install gh) + auth, npm for website build.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DRY_RUN=0
NO_GIT=0
NEW_VER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --no-git) NO_GIT=1 ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -n "$NEW_VER" ]]; then
        echo "Extra argument: $1" >&2
        exit 1
      fi
      NEW_VER="$1"
      ;;
  esac
  shift
done

if [[ -z "$NEW_VER" ]]; then
  echo "Usage: $0 [--dry-run] [--no-git] <new-marketing-version>" >&2
  echo "Example: $0 1.0.7" >&2
  echo "  Reads current version from Sources/IBStudy/Info.plist, bumps CFBundleVersion," >&2
  echo "  updates site/README URLs, builds IBStudy-macos.dmg, signs Sparkle, prepends appcast item," >&2
  echo "  commits, pushes, and creates the GitHub release (unless --dry-run or --no-git)." >&2
  exit 1
fi

if [[ ! "$NEW_VER" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: version must look like 1.2.3 (got: $NEW_VER)" >&2
  exit 1
fi

PLIST="$ROOT/Sources/IBStudy/Info.plist"
OLD_VER=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PLIST")
OLD_BUILD=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$PLIST")
NEW_BUILD=$((OLD_BUILD + 1))
TAG="v${NEW_VER}"

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "==> Would release marketing $NEW_VER (build $NEW_BUILD), tag $TAG (was $OLD_VER build $OLD_BUILD)"
  echo "    Files: Info.plist, website/app/page.tsx, website/README.md, README.md, docs/appcast.xml"
  echo "    Then: ./scripts/build-dmg.sh, sign_release, git commit/push, gh release create"
  exit 0
fi

echo "==> Releasing $NEW_VER (build $NEW_BUILD), was $OLD_VER (build $OLD_BUILD)"

# ── Info.plist ─────────────────────────────────────────────────────────────
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VER" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$PLIST"

# ── Marketing strings (same pattern as prior manual releases) ─────────────
if [[ "$OLD_VER" != "$NEW_VER" ]]; then
  for f in "$ROOT/website/app/page.tsx" "$ROOT/website/README.md" "$ROOT/README.md" "$ROOT/website/lib/site.ts"; do
    if [[ -f "$f" ]]; then
      # macOS sed in-place
      sed -i '' "s/${OLD_VER}/${NEW_VER}/g" "$f"
    fi
  done
fi

# ── DMG + Sparkle signature ─────────────────────────────────────────────────
echo "==> Building DMG"
"$ROOT/scripts/build-dmg.sh"

DMG="$ROOT/IBStudy-macos.dmg"
set +e
SIGN_OUT=$("$ROOT/scripts/sign-release.sh" "$DMG" 2>&1)
SIGN_RC=$?
set -e
echo "$SIGN_OUT"
if [[ "$SIGN_RC" -ne 0 ]]; then
  echo "error: sign-release failed (brew install --cask sparkle)" >&2
  exit 1
fi
SIG=$(echo "$SIGN_OUT" | sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p')
LEN=$(echo "$SIGN_OUT" | sed -n 's/.*length="\([0-9]*\)".*/\1/p')
if [[ -z "$SIG" || -z "$LEN" ]]; then
  echo "error: could not parse edSignature / length from sign_release output" >&2
  exit 1
fi

# ── Prepend Sparkle appcast item ────────────────────────────────────────────
PUB_DATE=$(LC_ALL=C date -u "+%a, %d %b %Y %H:%M:%S +0000")
export RELEASE_VER="$NEW_VER"
export RELEASE_BUILD="$NEW_BUILD"
export RELEASE_SIG="$SIG"
export RELEASE_LEN="$LEN"
export RELEASE_PUB="$PUB_DATE"
export RELEASE_APPCAST="$ROOT/docs/appcast.xml"

python3 <<'PY'
from pathlib import Path
import os
import textwrap

path = Path(os.environ["RELEASE_APPCAST"])
new_ver = os.environ["RELEASE_VER"]
new_build = os.environ["RELEASE_BUILD"]
sig = os.environ["RELEASE_SIG"]
length = os.environ["RELEASE_LEN"]
pub = os.environ["RELEASE_PUB"]

item = textwrap.dedent(f'''
\t\t<item>
\t\t\t<title>IBStudy v{new_ver}</title>
\t\t\t<sparkle:version>{new_build}</sparkle:version>
\t\t\t<sparkle:shortVersionString>{new_ver}</sparkle:shortVersionString>
\t\t\t<description><![CDATA[
\t\t\t\t<ul>
\t\t\t\t\t<li>See commit and release notes on GitHub.</li>
\t\t\t\t</ul>
\t\t\t]]></description>
\t\t\t<pubDate>{pub}</pubDate>
\t\t\t<enclosure
\t\t\t\turl="https://github.com/zBossPC/IB-Study-App/releases/download/v{new_ver}/IBStudy-macos.dmg"
\t\t\t\ttype="application/octet-stream"
\t\t\t\tsparkle:edSignature="{sig}"
\t\t\t\tlength="{length}"
\t\t\t/>
\t\t</item>
''')

text = path.read_text(encoding="utf-8")
needle = "\t\t<language>en</language>\n"
if needle not in text:
    raise SystemExit("appcast.xml: missing language line — abort")
path.write_text(text.replace(needle, needle + item, 1), encoding="utf-8")
print("==> Prepended Sparkle item to docs/appcast.xml")
PY


# ── Website production build ──────────────────────────────────────────────
echo "==> Website npm run build"
(
  cd "$ROOT/website"
  if [[ ! -d node_modules ]] || [[ ! -f node_modules/next/package.json ]]; then
    npm ci
  fi
  npm run build
)

if [[ "$NO_GIT" -eq 1 ]]; then
  echo ""
  echo "Done (--no-git): DMG at $DMG — commit and gh release yourself."
  exit 0
fi

# ── Git + GitHub ───────────────────────────────────────────────────────────
echo "==> Git commit + push"
git -C "$ROOT" add \
  "Sources/IBStudy/Info.plist" \
  "docs/appcast.xml" \
  "website/app/page.tsx" \
  "website/README.md" \
  "README.md" \
  "scripts/release.sh"

if ! git -C "$ROOT" diff --cached --quiet; then
  git -C "$ROOT" commit -m "Release v${NEW_VER} (build ${NEW_BUILD})"
else
  echo "warning: nothing staged — check git status" >&2
fi

git -C "$ROOT" push origin main

echo "==> GitHub release $TAG"
if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh not installed (brew install gh)" >&2
  exit 1
fi

NOTES_FILE="$(mktemp "${TMPDIR:-/tmp}/ibstudy-release-notes.XXXXXX")"
cat >"$NOTES_FILE" <<EOF
## IBStudy v${NEW_VER} (build ${NEW_BUILD})

- Sparkle auto-update via \`docs/appcast.xml\`
- Download **IBStudy-macos.dmg**, drag to **Applications**, open (unsigned: right-click → Open the first time).
EOF

if gh release view "$TAG" &>/dev/null; then
  echo "    Release exists — uploading DMG only"
  gh release upload "$TAG" "$DMG" --clobber
else
  gh release create "$TAG" "$DMG" --title "IBStudy v${NEW_VER}" --notes-file "$NOTES_FILE"
fi
rm -f "$NOTES_FILE"

echo ""
echo "Done. Release: https://github.com/zBossPC/IB-Study-App/releases/tag/$TAG"
