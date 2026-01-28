import AppKit

func generateIcon() {
    let size = CGSize(width: 1024, height: 1024)
    let image = NSImage(size: size)
    
    image.lockFocus()
    let fontSize: CGFloat = 800
    let font = NSFont.systemFont(ofSize: fontSize)
    let text = "📡" as NSString
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font
    ]
    
    let textSize = text.size(withAttributes: attributes)
    let rect = CGRect(
        x: (size.width - textSize.width) / 2,
        y: (size.height - textSize.height) / 2,
        width: textSize.width,
        height: textSize.height
    )
    
    text.draw(in: rect, withAttributes: attributes)
    image.unlockFocus()
    
    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        let url = URL(fileURLWithPath: "Icon.png")
        try? pngData.write(to: url)
        print("✅ Computed Icon.png with emoji 📡")
    } else {
        print("❌ Failed to generate icon")
        exit(1)
    }
}

generateIcon()
