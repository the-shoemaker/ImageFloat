import SwiftUI
import AppKit

@main
struct FloatingImageApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        configureWindow(window)
                    }
                }
        }
        .windowStyle(DefaultWindowStyle()) // Keep solid title bar
    }

    func configureWindow(_ window: NSWindow) {
        window.isOpaque = true
        window.backgroundColor = NSColor.clear // Fully transparent content area
        window.hasShadow = false
        window.titlebarAppearsTransparent = false // Solid title bar
        window.styleMask.insert(.fullSizeContentView)

        // Enable movement by dragging anywhere
        window.isMovableByWindowBackground = true

        // Set a solid gray title bar
        window.standardWindowButton(.closeButton)?.isHidden = false
        window.standardWindowButton(.miniaturizeButton)?.isHidden = false
        window.standardWindowButton(.zoomButton)?.isHidden = false
        window.titleVisibility = .visible
        window.title = "ImageFloat" // Set window title
    }
}
