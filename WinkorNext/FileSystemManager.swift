import Foundation
import SwiftUI

class FileSystemManager: ObservableObject {
    @Published var isSetupComplete = false
    @Published var setupStatus = "Initializing file system..."
    @Published var desktopURL: URL?
    
    // MARK: - Wine Paths
    private var winePrefixURL: URL?
    private var driveCURL: URL?
    private var desktopFolderURL: URL?
    
    // MARK: - Initialize Wine Environment
    func setupWineEnvironment() -> Bool {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            setupStatus = "❌ Could not access Documents directory"
            return false
        }
        
        winePrefixURL = documentsURL.appendingPathComponent("wine")
        driveCURL = winePrefixURL?.appendingPathComponent("drive_c")
        desktopFolderURL = driveCURL?.appendingPathComponent("users/Public/Desktop")
        
        setupStatus = "📁 Creating wine prefix..."
        
        do {
            // Create wine prefix directory
            try FileManager.default.createDirectory(at: winePrefixURL!, withIntermediateDirectories: true)
            
            // Check if C: drive already exists
            if FileManager.default.fileExists(atPath: driveCURL!.path) {
                setupStatus = "✅ C: drive already exists"
                isSetupComplete = true
                desktopURL = desktopFolderURL
                return true
            }
            
            // Create Windows directory structure
            setupStatus = "🏗️ Creating Windows directory structure..."
            guard createWindowsDirectoryStructure() else {
                return false
            }
            
            // Create D: drive symlink to Downloads
            setupStatus = "🔗 Creating D: drive symlink..."
            guard createDownloadsSymlink() else {
                return false
            }
            
            // Create basic Wine configuration files
            setupStatus = "⚙️ Creating Wine configuration..."
            guard createWineConfigFiles() else {
                return false
            }
            
            setupStatus = "✅ Wine environment setup complete!"
            isSetupComplete = true
            desktopURL = desktopFolderURL
            return true
            
        } catch {
            setupStatus = "❌ Failed to setup wine environment: \(error)"
            return false
        }
    }
    
    // MARK: - Create Windows Directory Structure
    private func createWindowsDirectoryStructure() -> Bool {
        guard let driveC = driveCURL else { return false }
        
        let windowsDirectories = [
            "windows",
            "windows/system32",
            "windows/Fonts",
            "users",
            "users/Program Files",
            "users/Program Files (x86)",
            "users/Public",
            "users/Public/Desktop",
            "users/Public/Documents",
            "users/Public/Downloads",
            "users/ProgramData",
            "temp",
            "Program Files",
            "Program Files (x86)"
        ]
        
        do {
            for directory in windowsDirectories {
                let dirURL = driveC.appendingPathComponent(directory)
                try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
                print("✅ Created: \(dirURL.path)")
            }
            return true
        } catch {
            setupStatus = "❌ Failed to create directory structure: \(error)"
            return false
        }
    }
    
    // MARK: - Create Downloads Symlink (D: drive)
    private func createDownloadsSymlink() -> Bool {
        guard let winePrefix = winePrefixURL else { return false }
        
        // Try to get iOS Downloads directory
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            setupStatus = "⚠️ Could not access iOS Downloads directory"
            return false
        }
        
        let symlinkURL = winePrefix.appendingPathComponent("dosdevices")
        let dDriveURL = symlinkURL.appendingPathComponent("d:")
        
        do {
            // Create dosdevices directory
            try FileManager.default.createDirectory(at: symlinkURL, withIntermediateDirectories: true)
            
            // Remove existing symlink if it exists
            if FileManager.default.fileExists(atPath: dDriveURL.path) {
                try FileManager.default.removeItem(at: dDriveURL)
            }
            
            // Create D: drive symlink to Downloads
            try FileManager.default.createSymbolicLink(at: dDriveURL, withDestinationURL: downloadsURL)
            print("✅ Created D: drive symlink to: \(downloadsURL.path)")
            return true
            
        } catch {
            setupStatus = "❌ Failed to create D: drive symlink: \(error)"
            return false
        }
    }
    
    // MARK: - Create Basic Wine Configuration
    private func createWineConfigFiles() -> Bool {
        guard let winePrefix = winePrefixURL else { return false }
        
        // Create basic system.reg file
        let systemRegContent = """
        WINE REGISTRY Version 2
        ;; All keys relative to \\Machine\\Software\\Microsoft\\Windows\\CurrentVersion
        
        [Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders]
        "Common Desktop"="C:\\users\\Public\\Desktop"
        "Common Documents"="C:\\users\\Public\\Documents"
        "Common Programs"="C:\\users\\ProgramData"
        "Common Start Menu"="C:\\ProgramData\\Microsoft\\Windows\\Start Menu"
        "Common Startup"="C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup"
        "Common Templates"="C:\\ProgramData\\Microsoft\\Windows\\Templates"
        "Desktop"="C:\\users\\Public\\Desktop"
        "Favorites"="C:\\users\\Public\\Favorites"
        "Personal"="C:\\users\\Public\\Documents"
        "Programs"="C:\\users\\Public\\Start Menu\\Programs"
        "Start Menu"="C:\\users\\Public\\Start Menu"
        "Startup"="C:\\users\\Public\\Start Menu\\Programs\\Startup"
        "Templates"="C:\\users\\Public\\Templates"
        
        [Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer]
        "NoDriveTypeAutoRun"=dword:00000091
        """
        
        let systemRegURL = winePrefix.appendingPathComponent("system.reg")
        do {
            try systemRegContent.write(to: systemRegURL, atomically: true, encoding: .utf8)
            print("✅ Created system.reg")
            return true
        } catch {
            setupStatus = "❌ Failed to create system.reg: \(error)"
            return false
        }
    }
    
    // MARK: - Get Desktop Files
    func getDesktopFiles() -> [URL] {
        guard let desktopURL = desktopFolderURL,
              FileManager.default.fileExists(atPath: desktopURL.path) else {
            return []
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: desktopURL,
                                                                  includingPropertiesForKeys: [.fileSizeKey, .creationDateKey],
                                                                  options: [.skipsHiddenFiles])
            return files.sorted { url1, url2 in
                // Directories first, then files
                let isDir1 = url1.hasDirectoryPath
                let isDir2 = url2.hasDirectoryPath
                if isDir1 != isDir2 {
                    return isDir1
                }
                return url1.lastPathComponent.localizedCaseInsensitiveCompare(url2.lastPathComponent) == .orderedAscending
            }
        } catch {
            print("❌ Failed to read desktop files: \(error)")
            return []
        }
    }
    
    // MARK: - Get Wine Prefix Path
    func getWinePrefixPath() -> String? {
        return winePrefixURL?.path
    }
    
    // MARK: - Check if Setup is Complete
    func isWineEnvironmentReady() -> Bool {
        guard let driveC = driveCURL else { return false }
        return FileManager.default.fileExists(atPath: driveC.path) && 
               FileManager.default.fileExists(atPath: desktopFolderURL?.path ?? "")
    }
}
