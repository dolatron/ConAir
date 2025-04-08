import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var micStatus = MicStatusManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        listenForConAirDaemon()
    }
    
    private func listenForConAirDaemon() {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(micStatus).toOpaque())
        CFNotificationCenterAddObserver(
            notificationCenter,
            observer,
            { _, observer, _, _, _ in
                let manager = Unmanaged<MicStatusManager>.fromOpaque(observer!).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.toggleMic()
                }
            },
            "ConAirButtonPressed" as CFString,
            nil,
            .deliverImmediately
        )
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        micStatus.refreshMicState()
        listenForConAirDaemon() // 🔥 Re-register listener on focus
    }
}

class MicStatusManager: ObservableObject {
    static let shared = MicStatusManager()
    @Published var isMuted: Bool = false
    private var lastToggleTime: Date = Date.distantPast
    
    init() {
        refreshMicState() // Get correct mic state at launch
        listenForConAirDaemon()
    }
    
    func toggleMic() {
        let now = Date()
        if now.timeIntervalSince(lastToggleTime) > 0.3 { // Debounce for 300ms
            let newMuteState = !isMuted
            let volumeScript = newMuteState ? "set volume input volume 0" : "set volume input volume 100"
            let script = "osascript -e \"\(volumeScript)\""
            _ = shell(script)
            DispatchQueue.main.async {
                self.isMuted = newMuteState
                self.objectWillChange.send()
            }
            lastToggleTime = now
        }
    }
    
    func refreshMicState() {
        let script = "osascript -e \"input volume of (get volume settings)\""
        if let result = shell(script)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            DispatchQueue.main.async {
                self.isMuted = (result == "0")
                self.objectWillChange.send()
            }
        }
    }
    
    private func listenForConAirDaemon() {
        let callback: CFNotificationCallback = { _, observer, _, _, _ in
            let manager = Unmanaged<MicStatusManager>.fromOpaque(observer!).takeUnretainedValue()
            DispatchQueue.main.async {
                manager.toggleMic()
            }
        }

        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            observer,
            callback,
            "ConAirButtonPressed" as CFString,
            nil,
            .deliverImmediately
        )
    }
    
    private func shell(_ command: String) -> String? {
        let process = Process()
        let pipe = Pipe()
        
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", command]
        process.standardOutput = pipe
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}
