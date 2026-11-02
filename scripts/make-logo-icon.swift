import AppKit

let imagePath = "/Users/omrajsawant/.gemini/antigravity/brain/02aed140-9a01-4252-9dea-2782747246e9/.user_uploaded/media_1793609979470_11c300af.jpg"
guard let sourceImage = NSImage(contentsOfFile: imagePath) else {
    fatalError("Could not load image at \(imagePath)")
}

let iconsetURL = URL(fileURLWithPath: "Packaging/AppIcon.iconset")
try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

func renderIcon(pixels: Int) -> Data {
    let size = CGFloat(pixels)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    
    // Inset ~10% for macOS squircle icon standard
    let inset = size * 0.1
    let rect = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let cornerRadius = rect.width * 0.225
    let clipPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    // Shadow behind the squircle
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.02)
    shadow.shadowBlurRadius = size * 0.04
    
    NSGraphicsContext.saveGraphicsState()
    shadow.set()
    NSColor.black.setFill()
    clipPath.fill()
    NSGraphicsContext.restoreGraphicsState()
    
    // Draw image inside squircle
    NSGraphicsContext.saveGraphicsState()
    clipPath.addClip()
    sourceImage.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
    
    // Subtle border overlay
    let borderPath = NSBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), xRadius: cornerRadius, yRadius: cornerRadius)
    borderPath.lineWidth = max(1.0, size * 0.002)
    NSColor(white: 1.0, alpha: 0.15).setStroke()
    borderPath.stroke()
    
    NSGraphicsContext.restoreGraphicsState()
    NSGraphicsContext.restoreGraphicsState()
    
    return rep.representation(using: .png, properties: [:])!
}

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

for (size, filename) in sizes {
    let data = renderIcon(pixels: size)
    try data.write(to: iconsetURL.appendingPathComponent(filename))
}
print("Generated iconset successfully.")
