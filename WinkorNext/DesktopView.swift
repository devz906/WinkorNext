import SwiftUI
import MetalKit

struct DesktopView: View {
    @ObservedObject var fileSystemManager: FileSystemManager
    @State private var selectedFile: URL?
    @State private var showingFileAlert = false
    @State private var alertMessage = ""
    @State private var showFileManager = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if !fileSystemManager.isSetupComplete {
                    // Setup in progress view
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text(fileSystemManager.setupStatus)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Metal View for Windows rendering
                    ZStack {
                        InteractiveMetalView()
                            .edgesIgnoringSafeArea(.all)
                        
                        // Overlay controls
                        VStack {
                            HStack {
                                // Close button
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                .padding(.leading)
                                
                                Spacer()
                                
                                // File manager toggle
                                Button(action: { showFileManager.toggle() }) {
                                    Image(systemName: "folder.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                .padding(.trailing)
                            }
                            .padding(.top)
                            
                            Spacer()
                            
                            // Status overlay
                            if !showFileManager {
                                HStack {
                                    Image(systemName: "gamecontroller.fill")
                                        .foregroundColor(.green)
                                    Text("Windows Desktop - Touch to control mouse")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(8)
                                }
                                .padding(.bottom)
                            }
                        }
                        
                        // File manager overlay
                        if showFileManager {
                            BlackTransparentBackground()
                            FileManagerOverlay(fileSystemManager: fileSystemManager) {
                                showFileManager = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Supporting Views
struct BlackTransparentBackground: View {
    var body: some View {
        Color.black.opacity(0.8)
            .edgesIgnoringSafeArea(.all)
    }
}

struct FileManagerOverlay: View {
    @ObservedObject var fileSystemManager: FileSystemManager
    let onClose: () -> Void
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button("Close") {
                    onClose()
                }
                .foregroundColor(.white)
                .padding()
                
                Spacer()
                
                Text("Windows Desktop Files")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    fileSystemManager.objectWillChange.send()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .background(Color.black.opacity(0.9))
            
            // File list
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(fileSystemManager.getDesktopFiles(), id: \.self) { file in
                        FileRowView(fileURL: file)
                    }
                }
                .padding()
            }
            .background(Color.black.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FileRowView: View {
    let fileURL: URL
    
    var body: some View {
        HStack {
            Image(systemName: fileURL.hasDirectoryPath ? "folder.fill" : getFileIcon())
                .foregroundColor(getFileColor())
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(fileURL.lastPathComponent)
                    .foregroundColor(.white)
                    .font(.body)
                
                if !fileURL.hasDirectoryPath {
                    Text(fileURL.pathExtension.uppercased())
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
    
    private func getFileIcon() -> String {
        let extension = fileURL.pathExtension.lowercased()
        switch extension {
        case "exe", "msi": return "terminal.fill"
        case "txt", "doc", "docx": return "doc.text.fill"
        case "jpg", "png", "gif": return "photo.fill"
        default: return "doc.fill"
        }
    }
    
    private func getFileColor() -> Color {
        let extension = fileURL.pathExtension.lowercased()
        switch extension {
        case "exe", "msi": return .green
        case "txt", "doc", "docx": return .blue
        case "jpg", "png", "gif": return .purple
        default: return .primary
        }
    }
}

#Preview {
    let fileManager = FileSystemManager()
    return DesktopView(fileSystemManager: fileManager)
}
