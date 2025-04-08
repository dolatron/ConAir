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
        let logPath = "\(FileManager.default.homeDirectoryForCurrentUser.path)/.conair_daemon/conair_daemon.log"
        let logMessage = "[\(Date())] \(message)\n"
        if let data = logMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logPath) {
                if let fileHandle = try? FileHandle(forWritingTo: URL(fileURLWithPath: logPath)) {
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