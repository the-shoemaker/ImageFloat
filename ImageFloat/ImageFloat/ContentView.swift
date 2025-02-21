import SwiftUI
import AppKit

struct ContentView: View {
    @State private var image: NSImage? = nil
    @State private var opacity: Double = 0.7
    @State private var alwaysOnTop: Bool = true
    @State private var showSettings: Bool = false
    @State private var imageOffset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @State private var imageScale: CGFloat = 1.0
    @State private var windowSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .opacity(opacity)
                    .offset(imageOffset)
                    .scaleEffect(imageScale)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                imageOffset = CGSize(width: value.translation.width, height: value.translation.height)
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                imageScale = value
                            }
                    )
                    .background(Color.clear)
                    .onTapGesture {
                        selectNewImage()
                    }
            } else {
                Text("Tap to select an image")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                    .onTapGesture {
                        selectNewImage()
                    }
            }
        }
        .frame(minWidth: 300, minHeight: 300)
        .background(Color.clear)
        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
            if let provider = providers.first {
                provider.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, _ in
                    if let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        if let nsImage = NSImage(contentsOf: url) {
                            DispatchQueue.main.async {
                                self.image = nsImage
                                resetImagePosition()
                            }
                        }
                    }
                }
            }
            return true
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                }
                .help("Show Settings")
            }
        }
        .sheet(isPresented: $showSettings) {
            VStack {
                HStack {
                    Text("Opacity")
                    Slider(value: $opacity, in: 0.2...1.0)
                }
                Toggle("Always on Top", isOn: $alwaysOnTop)
                    .onChange(of: alwaysOnTop) { _, newValue in
                        setAlwaysOnTop(newValue)
                    }
                
                Button("Reset Image Position") {
                    resetImagePosition()
                }
                
                HStack {
                    Text("Width:")
                    TextField("Width", value: $windowSize.width, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("Height:")
                    TextField("Height", value: $windowSize.height, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .onChange(of: windowSize) { _, _ in
                    resizeImageToWindow()
                }
                
                Button("Close Settings") {
                    showSettings = false
                }
                .padding(.top, 10)
            }
            .padding()
            .frame(width: 300)
        }
        .onAppear {
            setAlwaysOnTop(alwaysOnTop)
        }
    }
    
    private func selectNewImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url, let nsImage = NSImage(contentsOf: url) {
            self.image = nsImage
            resetImagePosition()
        }
    }
    
    private func setAlwaysOnTop(_ enabled: Bool) {
        if let window = NSApplication.shared.windows.first {
            window.level = enabled ? .floating : .normal
        }
    }
    
    private func resetImagePosition() {
        imageOffset = .zero
        imageScale = 1.0
    }
    
    private func resizeImageToWindow() {
        if let window = NSApplication.shared.windows.first {
            let newSize = CGSize(width: window.frame.width, height: window.frame.height)
            window.setFrame(NSRect(origin: window.frame.origin, size: newSize), display: true, animate: true)
        }
    }
}
