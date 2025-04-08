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

# Install ConAir Daemon
echo "Installing ConAir Daemon..."

# Create daemon directory
DAEMON_DIR="$HOME/.conair_daemon"
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
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
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

# Unload the Launch Agent if it exists, then load it
launchctl unload "$LAUNCH_AGENTS_DIR/com.conair.mic.daemon.plist" 2>/dev/null || true
launchctl load "$LAUNCH_AGENTS_DIR/com.conair.mic.daemon.plist"

# Install ConAir Widget
echo "Installing ConAir Widget..."

# Build the widget
cd "$PROJECT_ROOT/ConAirWidget"
xcodebuild -project ConAirWidget.xcodeproj -scheme ConAirWidget -configuration Release -derivedDataPath build CODE_SIGN_IDENTITY=- CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ ConAir Widget installed!${NC}"
else
    echo -e "${RED}❌ Failed to install ConAir Widget${NC}"
    exit 1
fi

# Copy the built widget to Applications
cp -R "build/Build/Products/Release/ConAirWidget.app" "/Applications/"

# Register with Launch Services
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "/Applications/ConAirWidget.app"

echo -e "${GREEN}✅ ConAir installation complete!${NC}"
echo "The widget will appear in your Notification Center."
echo "The daemon is running and will automatically start on login."
echo "Logs are available at: $DAEMON_DIR/conair_daemon.log" 