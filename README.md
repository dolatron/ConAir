# ConAir

ConAir is a macOS utility that automatically mutes/unmutes your AirPods when you click the microphone button. It consists of two main components:

1. A background daemon that monitors system logs for AirPods microphone button events
2. A macOS widget that provides a visual indicator of the microphone state

## Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later (for building)
- AirPods or other compatible Apple audio devices

## Installation

The installation process is now simplified with a single install script that handles both the daemon and widget installation:

```bash
# Make the install script executable
chmod +x scripts/install.sh

# Run the installer
./scripts/install.sh
```

This will:
- Remove any previous installation
- Install and start the ConAir daemon
- Build and install the ConAir widget
- Launch the widget automatically
- Configure everything to start automatically on login

The installer will provide feedback during the process and let you know when it's complete.

## Usage

Once installed, ConAir will automatically:
- Monitor your AirPods microphone button clicks
- Toggle the microphone mute state when the button is clicked
- Display the current microphone state in the widget

### Widget Features

The widget provides:
- Visual indicator of microphone mute state
- Quick access to mute/unmute controls
- Real-time status updates

### Troubleshooting

If you encounter any issues:

1. Check the daemon logs:
```bash
cat ~/.conair_daemon/conair_daemon.log
```

2. Try reinstalling:
```bash
./scripts/install.sh
```

3. Ensure your AirPods are properly connected and recognized by macOS

## Manual Uninstallation

While the installer will handle removing old versions automatically, you can manually uninstall ConAir by:

1. Stop and remove the daemon:
```bash
launchctl unload ~/Library/LaunchAgents/com.conair.mic.daemon.plist
rm ~/Library/LaunchAgents/com.conair.mic.daemon.plist
rm -rf ~/.conair_daemon
```

2. Remove the widget:
```bash
killall "ConAirWidget" 2>/dev/null || true
rm -rf "/Applications/ConAirWidget.app"
```

## License

[Your chosen license]

## Contributing

[Your contribution guidelines]

## Build Notes

The built app will be located at:
```
ConAirWidget/build/Build/Products/Release/ConAirWidget.app 