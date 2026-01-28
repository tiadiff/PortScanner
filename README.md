# Port Scanner for macOS

A high-performance, multi-threaded macOS security utility built with **Swift** and **SwiftUI**. It enables rapid network scanning with real-time process identification and management.

## Features
- **Multi-threaded Engine**: Scans hundreds of ports in seconds using native `async/await` and `TaskGroups`.
- **Process Identification**: Leverages `lsof` and root privileges to reveal which application is occupying a specific port.
- **Instant Termination**: Allows you to force-close (kill) any process directly from the UI.
- **Native UX**: Premium dark-mode interface with a dynamic emoji icon.
- **No-Xcode Build**: Includes a shell script to build the `.app` bundle from terminal.

## Requirements
- macOS 12.0 or newer.

## Building the App
Run the provided build script:
```bash
chmod +x build_app.sh
./build_app.sh
```
This will generate `PortScanner.app` in the project root.

## Usage
1. Open `PortScanner.app`.
2. Enter your administrator password when prompted (required for process identification and termination).
3. Enter target IP (default 127.0.0.1) and port range.
4. Click **Start Scan**.
