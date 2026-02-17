import SwiftUI
import MetalKit
import Metal

struct MetalViewRepresentable: UIViewRepresentable {
    @StateObject private var metalCoordinator = MetalCoordinator()
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        
        // Configure for A18 Pro GPU
        mtkView.device = MTLCreateSystemDefaultDevice()
        
        // Allow engine to write directly to screen (critical for MoltenVK)
        mtkView.framebufferOnly = false
        
        // Set up for high-performance rendering
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Configure for DirectX/Vulkan translation
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.colorPixelFormat = .bgra8Unorm
        
        // Set the delegate for rendering
        mtkView.delegate = context.coordinator
        
        // Enable user interaction for touch gestures
        mtkView.isUserInteractionEnabled = true
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Handle updates from SwiftUI
    }
    
    func makeCoordinator() -> MetalCoordinator {
        return metalCoordinator
    }
}

class MetalCoordinator: NSObject, MTKViewDelegate {
    var metalDevice: MTLDevice?
    var commandQueue: MTLCommandQueue?
    var renderPipelineState: MTLRenderPipelineState?
    
    // Mouse/touch coordinate tracking
    var mouseX: Float = 0.0
    var mouseY: Float = 0.0
    var mousePressed: Bool = false
    
    override init() {
        super.init()
        setupMetal()
    }
    
    func setupMetal() {
        // Get A18 Pro GPU device
        metalDevice = MTLCreateSystemDefaultDevice()
        guard let device = metalDevice else {
            print("❌ Could not create Metal device")
            return
        }
        
        // Create command queue
        commandQueue = device.makeCommandQueue()
        
        print("✅ Metal setup complete for A18 Pro GPU")
        print("🔧 GPU: \(device.name)")
    }
    
    // MARK: - MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle view size changes
        print("📱 Metal view size changed: \(size)")
    }
    
    func draw(in view: MTKView) {
        guard let device = metalDevice,
              let commandQueue = commandQueue,
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        // Create command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        // Create render command encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        // This is where winkor_engine will render via MoltenVK
        // For now, we'll just clear the screen with a dark color
        renderEncoder.setRenderPipelineState(createSimplePipelineState(device: device))
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.endEncoding()
        
        // Present the drawable
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func createSimplePipelineState(device: MTLDevice) -> MTLRenderPipelineState {
        // Simple pipeline state for clearing the screen
        // In production, this would be replaced by the engine's pipeline
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = false
        
        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Could not create pipeline state: \(error)")
        }
    }
    
    // MARK: - Mouse/Touch Input Handling
    func updateMousePosition(_ location: CGPoint, in view: MTKView) {
        // Convert SwiftUI coordinates to Metal coordinates (flip Y-axis)
        mouseX = Float(location.x)
        mouseY = Float(view.bounds.height - location.y)
        
        // Send coordinates to winkor_engine (Phase 5 implementation)
        sendMouseCoordinatesToEngine()
    }
    
    func setMousePressed(_ pressed: Bool) {
        mousePressed = pressed
        sendMouseCoordinatesToEngine()
    }
    
    private func sendMouseCoordinatesToEngine() {
        // This will be implemented in Phase 5 to communicate with winkor_engine
        print("🖱️ Mouse: X=\(mouseX), Y=\(mouseY), Pressed=\(mousePressed)")
        
        // TODO: Send coordinates to winkor_engine via IPC or shared memory
    }
}

// MARK: - Touch to Mouse Extension
extension MetalViewRepresentable {
    func setupTouchGestures(on view: MTKView, coordinator: MetalCoordinator) {
        // Drag gesture for mouse movement
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                coordinator.updateMousePosition(value.location, in: view)
                coordinator.setMousePressed(true)
            }
            .onEnded { value in
                coordinator.setMousePressed(false)
            }
        
        // Tap gesture for mouse clicks
        let tapGesture = TapGesture()
            .onEnded { location in
                coordinator.updateMousePosition(location, in: view)
                coordinator.setMousePressed(true)
                
                // Quick press and release for click
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    coordinator.setMousePressed(false)
                }
            }
        
        // Combine gestures
        let combined = dragGesture.simultaneously(with: tapGesture)
        
        // Add to view (this would need to be handled in the parent view)
    }
}

#Preview {
    MetalViewRepresentable()
        .frame(width: 300, height: 200)
        .background(Color.black)
}
