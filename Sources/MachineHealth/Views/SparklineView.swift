import Cocoa

final class SparklineView: NSView {
    private var points: [Double] = []
    private var lineColor: NSColor = .systemGreen

    private let axisHeight:  CGFloat = 16
    private let graphHeight: CGFloat = 44

    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: axisHeight + graphHeight)
    }

    func update(points: [Double], color: NSColor) {
        self.points = points
        self.lineColor = color
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        let dark = effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        let w = bounds.width
        let gBottom = axisHeight

        drawBackground(w: w, gBottom: gBottom, dark: dark)
        drawGrid(w: w, gBottom: gBottom, dark: dark)
        drawTimeAxis(w: w, dark: dark)
        guard points.count >= 2 else { return }
        drawFill(w: w, gBottom: gBottom, dark: dark)
        drawLine(w: w, gBottom: gBottom)
        drawEndDot(w: w, gBottom: gBottom, dark: dark)
    }

    private func drawBackground(w: CGFloat, gBottom: CGFloat, dark: Bool) {
        let color = dark
            ? NSColor(white: 0.0, alpha: 0.10)
            : NSColor(white: 0.0, alpha: 0.04)
        color.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: gBottom, width: w, height: graphHeight)).fill()
    }

    private func drawGrid(w: CGFloat, gBottom: CGFloat, dark: Bool) {
        let lineClr = dark
            ? NSColor(white: 1.0, alpha: 0.16)
            : NSColor(white: 0.0, alpha: 0.18)
        let borderClr = dark
            ? NSColor(white: 1.0, alpha: 0.30)
            : NSColor(white: 0.0, alpha: 0.30)
        let labelClr = dark
            ? NSColor.tertiaryLabelColor
            : NSColor.secondaryLabelColor

        let yLabelAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 7.5),
            .foregroundColor: labelClr
        ]

        for (frac, label) in [(0.25, "25%"), (0.5, "50%"), (0.75, "75%"), (1.0, "100%")] as [(CGFloat, String)] {
            let y = gBottom + frac * graphHeight
            let path = NSBezierPath()
            path.lineWidth = frac == 1.0 ? 0.75 : 0.5
            (frac == 1.0 ? borderClr : lineClr).setStroke()
            path.move(to: NSPoint(x: 0, y: y))
            path.line(to: NSPoint(x: w, y: y))
            path.stroke()

            if frac < 1.0 {
                let str = label as NSString
                let sz = str.size(withAttributes: yLabelAttrs)
                str.draw(at: NSPoint(x: w - sz.width - 3, y: y + 2), withAttributes: yLabelAttrs)
            }
        }

        let basePath = NSBezierPath()
        basePath.lineWidth = 0.75
        borderClr.setStroke()
        basePath.move(to: NSPoint(x: 0, y: gBottom))
        basePath.line(to: NSPoint(x: w, y: gBottom))
        basePath.stroke()
    }

    private func drawTimeAxis(w: CGFloat, dark: Bool) {
        let labelClr = dark ? NSColor.secondaryLabelColor : NSColor(white: 0.3, alpha: 1)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 8),
            .foregroundColor: labelClr
        ]
        for (text, fraction) in [("–5m", 0.0), ("–3m", 0.4), ("–1m", 0.8), ("now", 1.0)] as [(String, CGFloat)] {
            let str = text as NSString
            let size = str.size(withAttributes: attrs)
            let x = max(0, min(w - size.width, fraction * w - size.width / 2))
            str.draw(at: NSPoint(x: x, y: 2), withAttributes: attrs)
        }
    }

    private func pt(_ i: Int, w: CGFloat, gBottom: CGFloat) -> NSPoint {
        let n = CGFloat(points.count - 1)
        return NSPoint(
            x: CGFloat(i) / n * w,
            y: gBottom + max(0, min(graphHeight, CGFloat(points[i] / 100.0) * graphHeight))
        )
    }

    private func drawFill(w: CGFloat, gBottom: CGFloat, dark: Bool) {
        let fill = NSBezierPath()
        fill.move(to: NSPoint(x: 0, y: gBottom))
        for i in 0..<points.count { fill.line(to: pt(i, w: w, gBottom: gBottom)) }
        fill.line(to: NSPoint(x: w, y: gBottom))
        fill.close()
        lineColor.withAlphaComponent(dark ? 0.18 : 0.30).setFill()
        fill.fill()
    }

    private func drawLine(w: CGFloat, gBottom: CGFloat) {
        let line = NSBezierPath()
        line.lineWidth = 1.5
        line.lineCapStyle = .round
        line.lineJoinStyle = .round
        line.move(to: pt(0, w: w, gBottom: gBottom))
        for i in 1..<points.count { line.line(to: pt(i, w: w, gBottom: gBottom)) }
        lineColor.setStroke()
        line.stroke()
    }

    private func drawEndDot(w: CGFloat, gBottom: CGFloat, dark: Bool) {
        let last = pt(points.count - 1, w: w, gBottom: gBottom)
        let dot = NSBezierPath(ovalIn: NSRect(x: last.x - 3, y: last.y - 3, width: 6, height: 6))
        lineColor.setFill()
        dot.fill()
        let ringClr = dark
            ? NSColor(white: 0.15, alpha: 0.8)
            : NSColor(white: 1.00, alpha: 0.9)
        ringClr.setStroke()
        dot.lineWidth = 1.5
        dot.stroke()
    }
}
