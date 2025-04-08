import Foundation
import CoreAudio
import AVFoundation

class CoreAudioManager {
    static let shared = CoreAudioManager()
    private var audioDevice: AudioDeviceID = 0
    
    private init() {
        setupAudioDevice()
    }
    
    private func setupAudioDevice() {
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &audioDevice
        )
        
        if status != noErr {
            print("Error getting default input device: \(status)")
        }
    }
    
    func toggleMute() -> Bool {
        var muted: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        // Get current mute state
        let getStatus = AudioObjectGetPropertyData(
            audioDevice,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &muted
        )
        
        if getStatus != noErr {
            print("Error getting mute state: \(getStatus)")
            return false
        }
        
        // Toggle mute state
        muted = muted == 0 ? 1 : 0
        
        // Set new mute state
        let setStatus = AudioObjectSetPropertyData(
            audioDevice,
            &propertyAddress,
            0,
            nil,
            propertySize,
            &muted
        )
        
        if setStatus != noErr {
            print("Error setting mute state: \(setStatus)")
            return false
        }
        
        return true
    }
    
    func isMuted() -> Bool {
        var muted: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            audioDevice,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &muted
        )
        
        if status != noErr {
            print("Error getting mute state: \(status)")
            return false
        }
        
        return muted != 0
    }
} 