#!/bin/bash

APP_NAME="PortScanner"
APP_BUNDLE="$APP_NAME.app"
BINARY_NAME="PortScannerBin"
LAUNCHER_NAME="$APP_NAME"
SOURCES="PortScannerApp.swift ContentView.swift ScannerEngine.swift Models.swift ProcessManager.swift"
ICON_SOURCE="Icon.png"

echo "🚧 Building $APP_NAME..."

# 1. Compile the Swift sources
SDK_PATH=$(xcrun --show-sdk-path)
swiftc $SOURCES -o $BINARY_NAME -sdk "$SDK_PATH" -target x86_64-apple-macosx12.0 -parse-as-library

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed."
    exit 1
fi

echo "✅ Compilation successful."

# 2. Create the .app bundle structure
echo "📂 Creating .app bundle structure..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 3. Create App Icon
echo "🎨 Generating Emoji Icon..."
swift IconGen.swift
ICON_SOURCE="Icon.png"

if [ -f "$ICON_SOURCE" ]; then
    ICONSET_DIR="MyIcon.iconset"
    rm -rf "$ICONSET_DIR"
    mkdir -p "$ICONSET_DIR"
    
    # Generate standard icon sizes
    sips -z 16 16     -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16.png" > /dev/null
    sips -z 32 32     -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
    sips -z 32 32     -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32.png" > /dev/null
    sips -z 64 64     -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
    sips -z 128 128   -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128.png" > /dev/null
    sips -z 256 256   -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
    sips -z 256 256   -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256.png" > /dev/null
    sips -z 512 512   -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
    sips -z 512 512   -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512.png" > /dev/null
    sips -z 1024 1024 -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null
    
    # Convert iconset to icns
    if iconutil -c icns "$ICONSET_DIR"; then
        mv "MyIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
        echo "✅ Icon generated successfully."
    else
        echo "❌ Failed to generate .icns file."
    fi
    rm -rf "$ICONSET_DIR"
    rm "$ICON_SOURCE" # Cleanup intermediate file
else
    echo "⚠️  Failed to generate icon from script."
fi

# 4. Move binary
mv "$BINARY_NAME" "$APP_BUNDLE/Contents/MacOS/"

# 5. Create Launcher Script (for Root Privileges)
LAUNCHER_PATH="$APP_BUNDLE/Contents/MacOS/$LAUNCHER_NAME"
cat > "$LAUNCHER_PATH" <<EOF
#!/bin/bash
DIR=\$(dirname "\$0")
BINARY="\$DIR/$BINARY_NAME"
# Use AppleScript to relaunch with admin privileges
osascript -e "do shell script \"'\$BINARY'\" with administrator privileges"
EOF
chmod +x "$LAUNCHER_PATH"

# Force finder to refresh icon
touch "$APP_BUNDLE"

# 6. Create Info.plist
echo "📝 Generating Info.plist..."
cat > "$APP_BUNDLE/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$LAUNCHER_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2</string>
    <key>CFBundleVersion</key>
    <string>2</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "🎉 Done! You can now run the app by opening $APP_BUNDLE"
