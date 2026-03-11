#!/bin/bash
set -euo pipefail

# deskpals Release Build Script
# Builds, signs, notarizes, and packages deskpals.app for distribution
#
# Usage:
#   ./scripts/build-release.sh <version>
#   ./scripts/build-release.sh 1.0.0
#
# Environment variables (required for notarization):
#   DEVELOPER_ID_APPLICATION  - Signing identity (e.g., "Developer ID Application: Your Name (TEAMID)")
#   NOTARY_PROFILE            - Notarytool keychain profile name (default: "deskpals-notary")
#
# To store notarization credentials:
#   xcrun notarytool store-credentials "deskpals-notary" \
#     --apple-id "your@email.com" --team-id "TEAMID" --password "app-specific-password"

VERSION="${1:?Usage: $0 <version>}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="deskpals"
SCHEME="deskpals"
SIGNING_IDENTITY="${DEVELOPER_ID_APPLICATION:-}"
TEAM_ID="${APPLE_TEAM_ID:-}"
NOTARY_PROFILE="${NOTARY_PROFILE:-deskpals-notary}"

if [ -z "$SIGNING_IDENTITY" ]; then
  echo "ERROR: DEVELOPER_ID_APPLICATION is not set."
  echo "  Export it before running, e.g.:"
  echo "  export DEVELOPER_ID_APPLICATION=\"Developer ID Application: Your Name (TEAMID)\""
  exit 1
fi

echo "==> Building $APP_NAME v$VERSION..."

# Clean previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build release archive
xcodebuild \
  -project "$PROJECT_DIR/$APP_NAME.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
  archive \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  | tail -20

echo "==> Exporting app from archive..."

# Create export options plist for Developer ID distribution
cat > "$BUILD_DIR/ExportOptions.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
PLIST

# Export the archive
xcodebuild \
  -exportArchive \
  -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
  -exportPath "$BUILD_DIR/export" \
  -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist"

cp -R "$BUILD_DIR/export/$APP_NAME.app" "$BUILD_DIR/"

echo "==> Verifying code signature..."
codesign --verify --deep --strict "$BUILD_DIR/$APP_NAME.app"
codesign -dv --verbose=2 "$BUILD_DIR/$APP_NAME.app"

echo "==> Creating DMG..."
# Locate the app icon for the DMG volume icon
VOLICON="$BUILD_DIR/$APP_NAME.app/Contents/Resources/AppIcon.icns"
VOLICON_FLAG=""
if [ -f "$VOLICON" ]; then
  VOLICON_FLAG="--volicon $VOLICON"
fi

# create-dmg returns exit code 2 when it succeeds but "could not set icon"
# which is non-fatal, so we allow exit code 2
create-dmg \
  --volname "$APP_NAME $VERSION" \
  $VOLICON_FLAG \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 150 190 \
  --app-drop-link 450 190 \
  --no-internet-enable \
  "$BUILD_DIR/$APP_NAME-$VERSION.dmg" \
  "$BUILD_DIR/$APP_NAME.app" \
  || test $? -eq 2

echo "==> Notarizing DMG..."
xcrun notarytool submit "$BUILD_DIR/$APP_NAME-$VERSION.dmg" \
  --keychain-profile "$NOTARY_PROFILE" \
  --wait

echo "==> Stapling notarization ticket..."
xcrun stapler staple "$BUILD_DIR/$APP_NAME-$VERSION.dmg"

echo "==> Verifying notarization..."
xcrun stapler validate "$BUILD_DIR/$APP_NAME-$VERSION.dmg"
spctl --assess --type execute -v "$BUILD_DIR/$APP_NAME.app"

echo ""
echo "==> Build complete!"
echo "    DMG: $BUILD_DIR/$APP_NAME-$VERSION.dmg"
echo ""
echo "This build is signed with Developer ID and notarized."
echo "Users can open it without Gatekeeper warnings."
