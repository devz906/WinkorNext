import SwiftUI
import MetalKit

struct InteractiveMetalView: View {
    @StateObject private var metalCoordinator = MetalCoordinator()
    @State private var dragLocation: CGPoint = .zero
    
    var body: some View {
        MetalViewRepresentable()
            .coordinateSpace(name: "metalView")
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("metalView"))
                    .onChanged { value in
                        dragLocation = value.location
                        metalCoordinator.updateMousePosition(value.location, in: getMTKView())
                        metalCoordinator.setMousePressed(true)
                    }
                    .onEnded { value in
                        metalCoordinator.setMousePressed(false)
                    }
            )
            .simultaneousGesture(
                TapGesture(coordinateSpace: .named("metalView"))
                    .onEnded { location in
                        metalCoordinator.updateMousePosition(location, in: getMTKView())
                        metalCoordinator.setMousePressed(true)
                        
                        // Quick press and release for click
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            metalCoordinator.setMousePressed(false)
                        }
                    }
            )
            .onAppear {
                // Initialize the metal coordinator
                metalCoordinator.setupMetal()
            }
    }
    
    // Helper to get the underlying MTKView for coordinate conversion
    private func getMTKView() -> MTKView {
        // This is a simplified approach - in production, you'd want to maintain
        // a proper reference to the MTKView from the representable
        let mtkView = MTKView()
        mtkView.frame = UIScreen.main.bounds
        return mtkView
    }
}

// MARK: - Enhanced Metal Coordinator with Touch Support
extension MetalCoordinator {
    func setupTouchGestures() {
        print("🖱️ Touch gesture system ready for mouse input")
    }
    
    // Enhanced mouse coordinate handling with better precision
    func updateMousePosition(_ location: CGPoint, in view: MTKView) {
        // Convert touch coordinates to normalized device coordinates (0.0 to 1.0)
        let normalizedX = Float(location.x / view.bounds.width)
        let normalizedY = Float(location.y / view.bounds.height)
        
        // Store both raw and normalized coordinates
        mouseX = normalizedX * 2.0 - 1.0  // Convert to -1.0 to 1.0 range
        mouseY = 1.0 - (normalizedY * 2.0)  // Flip Y and convert to -1.0 to 1.0 range
        
        // Also store raw pixel coordinates for compatibility
        let rawX = Float(location.x)
        let rawY = Float(view.bounds.height - location.y)
        
        print("🖱️ Touch: (\(rawX), \(rawY)) -> Normalized: (\(mouseX), \(mouseY))")
        
        // Send coordinates to winkor_engine
        sendMouseCoordinatesToEngine(rawX: rawX, rawY: rawY)
    }
    
    private func sendMouseCoordinatesToEngine(rawX: Float, rawY: Float) {
        // This will be implemented in Phase 5 to communicate with winkor_engine
        // For now, we'll log the coordinates
        
        let mouseEvent = MouseEventData(
            x: rawX,
            y: rawY,
            button: mousePressed ? 1 : 0,
            timestamp: Date().timeIntervalSince1970
        )
        
        print("🖱️ Mouse Event: X=\(mouseEvent.x), Y=\(mouseEvent.y), Button=\(mouseEvent.button)")
        
        // TODO: Send to winkor_engine via:
        // - Shared memory
        // - Pipe/Socket
        // - File-based communication
    }
}

// MARK: - Mouse Event Data Structure
struct MouseEventData {
    let x: Float
    let y: Float
    let button: Int32  // 0 = none, 1 = left, 2 = right, 3 = middle
    let timestamp: TimeInterval
}

#Preview {
    InteractiveMetalView()
        .frame(width: 300, height: 200)
        .background(Color.black)
}
