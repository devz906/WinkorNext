import SwiftUI

struct ContentView: View {
    @StateObject private var engineManager = EngineManager()
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("WinkorNext")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("iOS 18 SwiftUI App")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Engine Status
            VStack(spacing: 15) {
                Button(action: {
                    if engineManager.isRunning {
                        engineManager.stop()
                    } else {
                        engineManager.launch()
                    }
                }) {
                    HStack {
                        Image(systemName: engineManager.isRunning ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(engineManager.isRunning ? "Stop Windows" : "Start Windows")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(engineManager.isRunning ? Color.red : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(engineManager.isRunning && engineManager.engineProcess == nil)
                
                // Status Message
                Text(engineManager.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Running Indicator
                if engineManager.isRunning {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Windows Engine Running...")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $engineManager.showDesktop) {
            DesktopView(fileSystemManager: engineManager.fileSystemManager)
        }
    }
}

#Preview {
    ContentView()
}
