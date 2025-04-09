#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Installing ConAir..."

# Uninstall old version first
echo "Removing old installation..."

# Stop and remove the old daemon
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
if [ -f "$LAUNCH_AGENTS_DIR/com.conair.mic.daemon.plist" ]; then
    launchctl unload "$LAUNCH_AGENTS_DIR/com.conair.mic.daemon.plist" 2>/dev/null || true
    rm "$LAUNCH_AGENTS_DIR/com.conair.mic.daemon.plist"
fi

# Remove old daemon directory
DAEMON_DIR="$HOME/.conair_daemon"
rm -rf "$DAEMON_DIR"

# Remove old app from Applications
if [ -d "/Applications/ConAir.app" ]; then
    # Force quit the app if it's running
    killall "ConAir" 2>/dev/null || true
    # Remove the app
    rm -rf "/Applications/ConAir.app"
fi

# Install ConAir Daemon
echo "Installing ConAir Daemon..."

# Create daemon directory
mkdir -p "$DAEMON_DIR"

# Copy daemon script
cp "$PROJECT_ROOT/ConAirDaemon/src/conair_daemon.swift" "$DAEMON_DIR/"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ ConAir Daemon installed!${NC}"
else
    echo -e "${RED}❌ Failed to install ConAir Daemon${NC}"
    exit 1
fi

# Create Launch Agent plist
mkdir -p "$LAUNCH_AGENTS_DIR"

cat > "$LAUNCH_AGENTS_DIR/com.conair.mic.daemon.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.conair.mic.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/swift</string>
        <string>$DAEMON_DIR/conair_daemon.swift</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$DAEMON_DIR/conair_daemon.log</string>
    <key>StandardOutPath</key>
    <string>$DAEMON_DIR/conair_daemon.log</string>
</dict>
</plist>
EOL

# Load the Launch Agent
launchctl load "$LAUNCH_AGENTS_DIR/com.conair.mic.daemon.plist"

# Install ConAir
echo "Installing ConAir..."

# Build the app
cd "$PROJECT_ROOT/ConAirWidget"
xcodebuild -project ConAirWidget.xcodeproj -scheme ConAir -configuration Release -derivedDataPath build CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ ConAir built successfully!${NC}"
else
    echo -e "${RED}❌ Failed to build ConAir${NC}"
    exit 1
fi

# Copy the built app to Applications
cp -R "build/Build/Products/Release/ConAir.app" "/Applications/ConAir.app"

# Register with Launch Services
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "/Applications/ConAir.app"

# Launch the app
open "/Applications/ConAir.app"

echo -e "${GREEN}✅ ConAir installation complete!${NC}"
echo "The app will appear in your menu bar."
echo "The daemon is running and will automatically start on login."
echo "Logs are available at: $DAEMON_DIR/conair_daemon.log" 