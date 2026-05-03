import Cocoa

let sizes = [16, 32, 64, 128, 256, 512, 1024]
let iconsetPath = "Resources/AppIcon.iconset"

try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for size in sizes {
    let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
        let bg = NSBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), xRadius: rect.width * 0.22, yRadius: rect.width * 0.22)

        let gradient = NSGradient(colors: [
            NSColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1),
            NSColor(red: 0.14, green: 0.14, blue: 0.22, alpha: 1)
        ], atLocations: [0.0, 1.0], colorSpace: .sRGB)!
        gradient.draw(in: bg, angle: -60)

        NSColor(white: 1.0, alpha: 0.08).setStroke()
        bg.lineWidth = max(1, CGFloat(size) / 128)
        bg.stroke()

        let symSize = CGFloat(size) * 0.52
        let cfg = NSImage.SymbolConfiguration(pointSize: symSize, weight: .medium)
        if let sym = NSImage(systemSymbolName: "desktopcomputer", accessibilityDescription: nil)?
            .withSymbolConfiguration(cfg) {
            sym.isTemplate = true
            let tinted = NSImage(size: sym.size, flipped: false) { r in
                NSColor.white.withAlphaComponent(0.92).setFill()
                sym.draw(in: r)
                return true
            }
            let x = (rect.width  - sym.size.width)  / 2
            let y = (rect.height - sym.size.height) / 2 - CGFloat(size) * 0.02
            tinted.draw(in: NSRect(x: x, y: y, width: sym.size.width, height: sym.size.height))
        }
        return true
    }

    func save(_ img: NSImage, to path: String) {
        guard let tiff = img.tiffRepresentation,
              let rep  = NSBitmapImageRep(data: tiff),
              let png  = rep.representation(using: .png, properties: [:]) else { return }
        try? png.write(to: URL(fileURLWithPath: path))
    }

    save(image, to: "\(iconsetPath)/icon_\(size)x\(size).png")
    if size <= 512 {
        save(image, to: "\(iconsetPath)/icon_\(size/2)x\(size/2)@2x.png")
    }
}

print("Iconset created at \(iconsetPath). Run: iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns")
