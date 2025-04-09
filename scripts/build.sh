#!/bin/bash

# Build script for ConAir
# This script builds the app and widget extension

# Configuration
APP_NAME="ConAir"
WIDGET_NAME="ConAirWidget"
SCHEME="ConAir"
CONFIGURATION="Release"
DERIVED_DATA_PATH="build"
ARCHIVE_PATH="build/ConAir.xcarchive"
EXPORT_PATH="build/ConAir"
EXPORT_OPTIONS_PLIST="ExportOptions.plist"

# Clean build directory
echo "Cleaning build directory..."
rm -rf "$DERIVED_DATA_PATH"
mkdir -p "$DERIVED_DATA_PATH"

# Build the app
echo "Building $APP_NAME..."
xcodebuild \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -archivePath "$ARCHIVE_PATH" \
    archive

# Export the app
echo "Exporting $APP_NAME..."
xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

echo "Build complete! App is available at: $EXPORT_PATH/$APP_NAME.app" 