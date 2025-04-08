# ConAir

ConAir is a macOS utility that automatically mutes/unmutes your AirPods when you click the microphone button. It consists of two main components:

1. A background daemon that monitors system logs for AirPods microphone button events
2. A macOS widget that provides a visual indicator of the microphone state

## Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later (for building the widget)
- AirPods or other compatible Apple audio devices

## Installation

### 1. Install the Daemon

Run the installation script in your terminal:

```bash
chmod +x install_conair_daemon.sh
./install_conair_daemon.sh
```

This will:
- Create a daemon directory at `~/.conair_daemon`
- Install the daemon script
- Create and load a Launch Agent to run the daemon automatically
- Start the daemon service

### 2. Install the Widget

1. Open the `ConAirWidget.xcodeproj` in Xcode
2. Build and run the project (⌘R)
3. The widget will be installed in your Notification Center

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

2. Restart the daemon:
```bash
launchctl unload ~/Library/LaunchAgents/com.conair.mic.daemon.plist
launchctl load ~/Library/LaunchAgents/com.conair.mic.daemon.plist
```

3. Ensure your AirPods are properly connected and recognized by macOS

## Uninstallation

To remove ConAir:

1. Unload and remove the daemon:
```bash
launchctl unload ~/Library/LaunchAgents/com.conair.mic.daemon.plist
rm ~/Library/LaunchAgents/com.conair.mic.daemon.plist
rm -rf ~/.conair_daemon
```

2. Remove the widget from your Notification Center

## License

[Your chosen license]

## Contributing

[Your contribution guidelines] 

## Build Notes

The built app will be located at:
```
ConAirWidget/build/Build/Products/Release/ConAirWidget.app 