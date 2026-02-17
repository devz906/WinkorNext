import Foundation
import SwiftUI

class EngineManager: ObservableObject {
    @Published var isRunning = false
    @Published var statusMessage = "Ready to launch Windows"
    @Published var engineProcess: Process?
    @Published var fileSystemManager = FileSystemManager()
    @Published var showDesktop = false
    
    // MARK: - Engine Location
    private func getEngineURL() -> URL? {
        guard let engineURL = Bundle.main.url(forResource: "winkor_engine", withExtension: nil) else {
            print("❌ Could not find winkor_engine in bundle")
            return nil
        }
        return engineURL
    }
    
    // MARK: - Permissions Check
    private func ensureExecutePermissions(for url: URL) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/chmod")
        process.arguments = ["+x", url.path]
        
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            print("❌ Failed to set execute permissions: \(error)")
            return false
        }
    }
    
    // MARK: - Wine Setup
    private func setupWine() -> Bool {
        print("🔧 Setting up Wine environment...")
        
        // Use FileSystemManager to setup the complete Wine environment
        let success = fileSystemManager.setupWineEnvironment()
        
        if success {
            print("✅ Wine environment setup complete")
            statusMessage = fileSystemManager.setupStatus
        } else {
            print("❌ Wine environment setup failed")
            statusMessage = fileSystemManager.setupStatus
        }
        
        return success
    }
    
    // MARK: - Environment Variables for A18 Pro
    private func getEnvironmentVariables() -> [String: String] {
        // Get the wine prefix path from FileSystemManager
        guard let winePrefix = fileSystemManager.getWinePrefixPath() else {
            return [:]
        }
        
        return [
            "BOX64_DYNAREC": "1",                                    // Speed optimization
            "BOX64_PAGE16K": "1",                                    // iPhone 16 Pro alignment
            "WINEPREFIX": winePrefix,                                // Virtual C: drive location
            "MVK_CONFIG_RESUME_MODIFY_DEFAULT_PIPELINE_CACHE": "1",   // Faster graphics loading
            "MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS": "1",            // Huge speed boost for A18 Pro
            "DXVK_HUD": "compiler",                                   // Shows overlay for graphics debugging
            "MVK_CONFIG_SYNC_DISPLAY_BUFFER_UPDATES": "1"             // Better frame synchronization
        ]
    }
    
    // MARK: - Launch Engine
    func launch() {
        guard !isRunning else {
            statusMessage = "⚠️ Engine is already running"
            return
        }
        
        // Step 1: Locate engine
        guard let engineURL = getEngineURL() else {
            statusMessage = "❌ Could not find winkor_engine"
            return
        }
        
        statusMessage = "🔍 Found winkor_engine at: \(engineURL.path)"
        
        // Step 2: Check permissions
        guard ensureExecutePermissions(for: engineURL) else {
            statusMessage = "❌ Failed to set execute permissions"
            return
        }
        
        statusMessage = "✅ Execute permissions set"
        
        // Step 3: Setup Wine
        guard setupWine() else {
            statusMessage = "❌ Wine setup failed"
            return
        }
        
        statusMessage = "🍷 Wine environment ready"
        
        // Step 4: Launch process
        let process = Process()
        process.executableURL = engineURL
        process.environment = getEnvironmentVariables()
        
        // Capture output
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            engineProcess = process
            isRunning = true
            statusMessage = "🚀 Windows engine launched successfully!"
            
            // Show desktop after successful launch
            showDesktop = true
            
            // Monitor process in background
            DispatchQueue.global().async {
                process.waitUntilExit()
                DispatchQueue.main.async {
                    self.isRunning = false
                    self.statusMessage = process.terminationStatus == 0 ? 
                        "✅ Engine completed successfully" : 
                        "❌ Engine exited with code: \(process.terminationStatus)"
                    self.engineProcess = nil
                }
            }
            
        } catch {
            statusMessage = "❌ Failed to launch engine: \(error)"
        }
    }
    
    // MARK: - Stop Engine
    func stop() {
        guard let process = engineProcess else { return }
        
        process.terminate()
        engineProcess = nil
        isRunning = false
        statusMessage = "🛑 Engine stopped"
    }
}
