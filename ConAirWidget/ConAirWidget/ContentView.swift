import SwiftUI
import Cocoa

struct ContentView: View {
    @ObservedObject var micStatus = MicStatusManager.shared
    @State private var dragOffset = CGSize.zero

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: micStatus.isMuted ? "mic.slash.fill" : "mic.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(micStatus.isMuted ? "Microphone Muted" : "Microphone Active")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .frame(height: 25)
            .frame(maxWidth: .infinity)
            .background(
                (micStatus.isMuted ? Color.red : Color.green)
                    .opacity(0.4)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if let window = NSApplication.shared.windows.first {
                            let newPosition = CGPoint(
                                x: window.frame.origin.x + value.translation.width,
                                y: window.frame.origin.y - value.translation.height
                            )
                            window.setFrameOrigin(newPosition)
                        }
                    }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .background(.clear)
        .onTapGesture {
            micStatus.toggleMic()
        }
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                window.isMovableByWindowBackground = true // Ensures dragging works
                window.styleMask.remove(.titled) // Removes title bar
                window.backgroundColor = .clear
                window.isOpaque = false
            }
        }
    }
}
