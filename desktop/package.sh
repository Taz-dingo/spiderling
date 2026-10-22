#!/usr/bin/env bash
# Build a self-contained, ad-hoc signed macOS preview. Run with: bash desktop/package.sh
# Requires macOS, Xcode Command Line Tools, and the built-in ditto/codesign tools.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Spiderling.app"
CONTENT="$APP/Contents"

rm -rf "$APP"
mkdir -p "$CONTENT/MacOS" "$CONTENT/Resources"

swiftc -O -target "$(uname -m)-apple-macosx12.0" \
  -module-cache-path "${TMPDIR:-/tmp}/spiderling-clangmod" \
  "$ROOT/desktop/HostGeometry.swift" "$ROOT/desktop/SpiderPet.swift" \
  -o "$CONTENT/MacOS/Spiderling"

cp "$ROOT/index.html" "$ROOT/app.js" "$ROOT/style.css" "$CONTENT/Resources/"
cp -R "$ROOT/src" "$ROOT/vendor" "$CONTENT/Resources/"

cat > "$CONTENT/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>Spiderling</string>
  <key>CFBundleIdentifier</key><string>dev.tazdingo.spiderling</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>Spiderling</string>
  <key>CFBundleDisplayName</key><string>Spiderling</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.0.1</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

plutil -lint "$CONTENT/Info.plist"
# This is ad-hoc signing for bundle integrity only: NOT Developer ID signing
# and NOT notarization. A downloaded preview may be blocked by Gatekeeper.
codesign --force --sign - "$APP"
codesign --verify --deep --strict "$APP"

ARCH="$(uname -m)"
ZIP="$ROOT/dist/Spiderling-macos-$ARCH.zip"
rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"
echo "Built $ZIP (ad-hoc signed, not notarized)"
