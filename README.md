# WinkorNext - Windows on iPhone 16 Pro

🚀 **Run Windows applications natively on iPhone 16 Pro with A18 Pro GPU acceleration**

## 📱 Overview

WinkorNext is a revolutionary iOS application that brings full Windows compatibility to iPhone 16 Pro using advanced virtualization technology. Leveraging the power of the A18 Pro GPU and MoltenVK translation, WinkorNext delivers near-native performance for Windows applications and games.

## ✨ Key Features

### 🎮 **Graphics Performance**
- **A18 Pro GPU Acceleration**: Direct Metal API access through MoltenVK
- **DXVK Integration**: DirectX to Vulkan translation for maximum compatibility
- **60 FPS Rendering**: Smooth graphics performance with optimized pipeline
- **Real-time Display**: Full-screen Windows environment with touch controls

### 🖱️ **Input System**
- **Touch-to-Mouse**: Precise finger-to-mouse coordinate conversion
- **Gesture Support**: Drag, tap, and multi-touch gestures
- **Real-time Response**: Immediate input feedback with zero lag

### 💾 **Virtual Environment**
- **Complete C: Drive**: Full Windows directory structure
- **D: Drive Access**: Direct access to iOS Downloads folder
- **Wine Integration**: Advanced Wine configuration for compatibility
- **8GB RAM Support**: Increased memory limit for demanding applications

### 🔧 **Technical Excellence**
- **iOS 18 Optimized**: Built specifically for iPhone 16 Pro
- **No Emulation**: Native translation vs. emulation for performance
- **Metal Argument Buffers**: Massive speed boost for A18 Pro
- **JIT Compilation**: Just-in-time execution support

## 🏗️ Architecture

```
WinkorNext/
├── Engine/                    # winkor_engine binary
├── Frameworks/               # MoltenVK static libraries
├── WinkorNext/
│   ├── EngineManager.swift   # Main engine controller
│   ├── FileSystemManager.swift # Virtual drive management
│   ├── MetalViewRepresentable.swift # GPU rendering
│   ├── InteractiveMetalView.swift # Touch input
│   └── DesktopView.swift     # Windows desktop UI
└── WinkorNext.entitlements   # iOS permissions
```

## 🚀 Getting Started

### Automatic Build (Recommended)

1. **Download IPA**: Go to the [Actions tab](https://github.com/devz906/WinkorNext/actions) and download the latest `WinkorNext.ipa`
2. **Install**: Use AltStore, Sideloadly, or similar sideloading tool
3. **Trust**: Go to Settings > General & VPN > Device Management and trust the developer
4. **Launch**: Open WinkorNext and tap "Start Windows"

### Manual Build

```bash
# Clone the repository
git clone https://github.com/devz906/WinkorNext.git
cd WinkorNext

# Build with Xcode (requires macOS)
xcodebuild -project WinkorNext.xcodeproj \
  -scheme WinkorNext \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO
```

## 🎯 Usage

### First Time Setup
1. **Launch WinkorNext** from your Home Screen
2. **Tap "Start Windows"** to initialize the environment
3. **Wait for setup** - Wine environment and virtual drives are created
4. **Access Desktop** - Full Windows desktop appears with touch controls

### Installing Applications
1. **Download .exe files** to your iOS Downloads folder
2. **Access D: drive** in Windows - it's linked to your Downloads
3. **Run installers** - Double-tap to execute Windows applications
4. **Find shortcuts** on the Windows desktop

### Touch Controls
- **Single Tap**: Left mouse click
- **Drag**: Mouse movement
- **Long Press**: Right mouse click
- **Pinch**: Zoom (in compatible applications)

## 🔧 Technical Details

### GPU Acceleration
- **MoltenVK**: Vulkan to Metal translation layer
- **DXVK**: DirectX to Vulkan for game compatibility
- **Metal Argument Buffers**: Optimized for A18 Pro architecture
- **Direct Screen Writing**: `framebufferOnly = false` for performance

### Environment Variables
```bash
BOX64_DYNAREC=1                    # Speed optimization
BOX64_PAGE16K=1                    # iPhone 16 Pro alignment
WINEPREFIX=[Documents]/wine        # Virtual C: drive
MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS=1  # A18 Pro boost
DXVK_HUD=compiler                  # Graphics debugging
```

### File System Structure
```
Documents/wine/
├── drive_c/
│   ├── windows/
│   ├── users/
│   │   ├── Program Files/
│   │   └── Public/Desktop/
│   └── Program Files/
└── dosdevices/
    ├── c: -> drive_c/
    └── d: -> ../Downloads/
```

## 📋 Requirements

- **Device**: iPhone 16 Pro (A18 Pro chip required)
- **iOS Version**: iOS 18.0 or later
- **Storage**: 2GB free space for virtual environment
- **Memory**: 8GB RAM for optimal performance
- **Network**: Internet connection for initial setup

## ⚠️ Important Notes

### Performance
- **Native Translation**: Uses MoltenVK translation, not emulation
- **GPU Direct Access**: Bypasses emulation layers for speed
- **Memory Optimized**: Configured for 8GB iPhone 16 Pro RAM

### Compatibility
- **Windows Applications**: Most Windows 10/11 applications supported
- **Games**: DirectX 9/11/12 games with DXVK
- **Productivity**: Office suites, development tools, utilities

### Limitations
- **A18 Pro Required**: Optimized specifically for iPhone 16 Pro hardware
- **Sideloading Only**: Not available on App Store (requires developer permissions)
- **Battery Usage**: High-performance applications may drain battery faster

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
```bash
# Clone with submodules
git clone --recursive https://github.com/devz906/WinkorNext.git

# Open in Xcode
open WinkorNext.xcodeproj
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **MoltenVK Team**: For the amazing Vulkan to Metal translation
- **Wine Project**: For the Windows compatibility layer
- **DXVK**: For DirectX to Vulkan translation
- **Apple**: For the powerful A18 Pro and Metal API

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/devz906/WinkorNext/issues)
- **Discussions**: [GitHub Discussions](https://github.com/devz906/WinkorNext/discussions)
- **Updates**: Follow for latest features and improvements

---

**⚡ Powered by A18 Pro • Built for iPhone 16 Pro • Windows Anywhere**
