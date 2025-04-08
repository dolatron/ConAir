import SwiftUI

@main
struct ConAirWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Window("ConAir", id: "main") {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.clear)
        }
        .windowStyle(.hiddenTitleBar)
        .windowLevel(.floating)
        .defaultSize(width: NSScreen.main?.frame.width ?? 800, height: 25)
        .defaultPosition(.topLeading)
        .windowResizability(.contentMinSize)
    }
}
