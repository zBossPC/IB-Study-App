#!/usr/bin/env bash
# IBStudy release helper — build DMG, Sparkle signature, optional GitHub upload + website build.
# For a full version bump + appcast + git + GitHub release, use ./scripts/release.sh <version> instead.
# Usage:
#   ./scripts/publish.sh              # build DMG + print Sparkle attrs + appcast reminder
#   ./scripts/publish.sh --upload     # also: gh release upload (needs gh auth + existing release tag)
#   ./scripts/publish.sh --site       # also: npm ci (if needed) + npm run build in website/
#   ./scripts/publish.sh --vercel     # also: vercel --prod from website/ (needs Vercel CLI + login)
#   ./scripts/publish.sh --ship       # --upload + --site (full local ship)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

UPLOAD=0
SITE=0
VERCEL=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --upload) UPLOAD=1 ;;
    --site) SITE=1 ;;
    --vercel) VERCEL=1 ;;
    --ship)
      UPLOAD=1
      SITE=1
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--upload] [--site] [--vercel] [--ship]" >&2
      exit 1
      ;;
  esac
  shift
done

PLIST="$ROOT/Sources/IBStudy/Info.plist"
SHORT=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PLIST")
BUILD=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$PLIST")
TAG="v${SHORT}"

echo "==> Version ${SHORT} (build ${BUILD}) tag ${TAG}"
echo "==> Building DMG"
"$ROOT/scripts/build-dmg.sh"

DMG="$ROOT/IBStudy-macos.dmg"
if [[ ! -f "$DMG" ]]; then
  echo "error: $DMG missing after build" >&2
  exit 1
fi

echo ""
echo "==> Sparkle (add a new first <item> in docs/appcast.xml if build number changed)"
set +e
SIGN_OUT=$("$ROOT/scripts/sign-release.sh" "$DMG" 2>&1)
SIGN_RC=$?
set -e
echo "$SIGN_OUT"
if [[ "$SIGN_RC" -ne 0 ]]; then
  echo "warning: sign-release failed (install: brew install --cask sparkle). Fix signing before shipping Sparkle updates." >&2
fi
SIG=""
LEN=""
if [[ "$SIGN_RC" -eq 0 ]]; then
  SIG=$(echo "$SIGN_OUT" | sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p')
  LEN=$(echo "$SIGN_OUT" | sed -n 's/.*length="\([0-9]*\)".*/\1/p')
fi
if [[ -n "$SIG" && -n "$LEN" ]]; then
  echo ""
  echo "--- Paste into docs/appcast.xml (adjust title/description/pubDate) ---"
  cat <<EOF
		<item>
			<title>IBStudy v${SHORT}</title>
			<sparkle:version>${BUILD}</sparkle:version>
			<sparkle:shortVersionString>${SHORT}</sparkle:shortVersionString>
			<sparkle:minimumSystemVersion>26.0</sparkle:minimumSystemVersion>
			<description><![CDATA[
				<ul>
					<li>See commit / release notes</li>
				</ul>
			]]></description>
			<pubDate>$(LC_ALL=C date -u "+%a, %d %b %Y %H:%M:%S +0000")</pubDate>
			<enclosure
				url="https://github.com/zBossPC/IB-Study-App/releases/download/${TAG}/IBStudy-macos.dmg"
				type="application/octet-stream"
				sparkle:edSignature="${SIG}"
				length="${LEN}"
			/>
		</item>
EOF
  echo "--- end paste ---"
  echo ""
fi

if [[ "$UPLOAD" -eq 1 ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "error: gh not found. Install: brew install gh && gh auth login" >&2
    exit 1
  fi
  echo "==> Uploading DMG to GitHub release ${TAG}"
  gh release upload "$TAG" "$DMG" --clobber
  echo "    Uploaded."
fi

if [[ "$SITE" -eq 1 ]]; then
  echo "==> Website production build"
  cd "$ROOT/website"
  if [[ ! -d node_modules ]] || [[ ! -f node_modules/next/package.json ]]; then
    echo "    Running npm ci..."
    npm ci
  fi
  npm run build
  echo "    website/ build OK."
fi

if [[ "$VERCEL" -eq 1 ]]; then
  if ! command -v vercel >/dev/null 2>&1; then
    echo "error: vercel CLI not found. Install: npm i -g vercel" >&2
    exit 1
  fi
  echo "==> Vercel production deploy (website/)"
  cd "$ROOT/website"
  vercel --prod
fi

echo ""
echo "Done. If Vercel is linked to the repo, git push may deploy the site automatically."
