import Cocoa

final class ToastNotification {
    private static var active: [NSPanel] = []
    private static let width:  CGFloat = 310
    private static let height: CGFloat = 68

    static func show(title: String, body: String, symbol: String = "exclamationmark.triangle.fill", tint: NSColor = .systemOrange) {
        DispatchQueue.main.async {
            let panel = build(title: title, body: body, symbol: symbol, tint: tint)
            position(panel)
            panel.alphaValue = 0
            panel.orderFrontRegardless()
            active.append(panel)

            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.2
                panel.animator().alphaValue = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                dismiss(panel)
            }
        }
    }

    private static func dismiss(_ panel: NSPanel) {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.3
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
            active.removeAll { $0 === panel }
        })
    }

    private static func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }
        let offset = CGFloat(active.count) * (height + 10)
        let x = screen.frame.maxX - width - 16
        let y = screen.visibleFrame.maxY - height - 8 - offset
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private static func build(title: String, body: String, symbol: String, tint: NSColor) -> NSPanel {
        let rect = NSRect(x: 0, y: 0, width: width, height: height)
        let panel = NSPanel(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.ignoresMouseEvents = true

        let container = NSView(frame: rect)
        container.wantsLayer = true
        container.layer?.cornerRadius = 12
        container.layer?.masksToBounds = true

        let blur = NSVisualEffectView(frame: rect)
        blur.material = .hudWindow
        blur.blendingMode = .behindWindow
        blur.state = .active
        container.addSubview(blur)

        let accent = NSView(frame: NSRect(x: 0, y: 0, width: 4, height: height))
        accent.wantsLayer = true
        accent.layer?.backgroundColor = tint.cgColor
        container.addSubview(accent)

        let iconView = NSImageView(frame: NSRect(x: 14, y: (height - 22) / 2, width: 22, height: 22))
        if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) {
            let cfg = NSImage.SymbolConfiguration(pointSize: 17, weight: .medium)
            iconView.image = img.withSymbolConfiguration(cfg)
            iconView.contentTintColor = tint
        }
        container.addSubview(iconView)

        let textX: CGFloat = 46
        let textW = width - textX - 12

        let titleField = NSTextField(labelWithString: title)
        titleField.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        titleField.textColor = .labelColor
        titleField.frame = NSRect(x: textX, y: height / 2 + 1, width: textW, height: 17)
        container.addSubview(titleField)

        let bodyField = NSTextField(labelWithString: body)
        bodyField.font = NSFont.systemFont(ofSize: 11)
        bodyField.textColor = .secondaryLabelColor
        bodyField.frame = NSRect(x: textX, y: height / 2 - 16, width: textW, height: 14)
        container.addSubview(bodyField)

        panel.contentView = container
        return panel
    }
}
