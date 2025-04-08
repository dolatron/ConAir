#!/bin/bash

LAUNCH_AGENT_PATH="$HOME/Library/LaunchAgents/com.conair.mic.daemon.plist"
DAEMON_PATH="$HOME/.conair_daemon"

# Create directory for daemon
mkdir -p "$DAEMON_PATH"

# Move daemon script
cat > "$DAEMON_PATH/conair_daemon.swift" <<EOL
#!/usr/bin/swift

import Foundation

class ConAirDaemon {
    private let process = Process()
    private let pipe = Pipe()
    
    init() {
        log("Initializing ConAir Daemon...")
        process.launchPath = "/usr/bin/log"
        process.arguments = ["stream", "--predicate", "eventMessage contains \"input mute candidate\""]
        process.standardOutput = pipe
        process.terminationHandler = { _ in self.restartDaemon() }
    }
    
    func start() {
        log("Starting ConAir Daemon...")
        let fileHandle = pipe.fileHandleForReading
        NotificationCenter.default.addObserver(self, selector: #selector(readLog(_:)), name: FileHandle.readCompletionNotification, object: fileHandle)
        fileHandle.readInBackgroundAndNotify()
        process.launch()
    }
    
    @objc private func readLog(_ notification: Notification) {
        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data,
           let logMessage = String(data: data, encoding: .utf8) {
            log("Daemon Log: \(logMessage)")
            
            // Ensure only headset-related Bluetooth events trigger the action
            if logMessage.contains("input mute candidate") && 
            logMessage.contains("com.apple.coreaudio") {
                postNotification()
            }
        }
        pipe.fileHandleForReading.readInBackgroundAndNotify()
    }
    
    private func postNotification() {
        log("Sending ConAirButtonPressed Darwin notification...")
        
        let task = Process()
        task.launchPath = "/usr/bin/notifyutil"
        task.arguments = ["-p", "ConAirButtonPressed"]
        task.launch()
    }

    private func restartDaemon() {
        log("Daemon restarting...")
        start()
    }
    
    private func log(_ message: String) {
        let logPath = "$HOME/.conair_daemon/conair_daemon.log"
        let logMessage = "[\(Date())] \(message)\n"
        if let data = logMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logPath) {
                if let fileHandle = FileHandle(forWritingAtPath: logPath) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: URL(fileURLWithPath: logPath))
            }
        }
    }
}

let daemon = ConAirDaemon()
daemon.start()

RunLoop.main.run()
EOL

# Make script executable
chmod +x "$DAEMON_PATH/conair_daemon.swift"

# Create Launch Agent plist file
cat > "$LAUNCH_AGENT_PATH" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.conair.mic.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/swift</string>
        <string>$DAEMON_PATH/conair_daemon.swift</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$DAEMON_PATH/output.log</string>
    <key>StandardErrorPath</key>
    <string>$DAEMON_PATH/error.log</string>
</dict>
</plist>
EOL

# Load the Launch Agent
launchctl unload "$LAUNCH_AGENT_PATH"
launchctl load "$LAUNCH_AGENT_PATH"

echo "✅ ConAir mic daemon installed and running! Check logs at ~/.conair_daemon/conair_daemon.log"
