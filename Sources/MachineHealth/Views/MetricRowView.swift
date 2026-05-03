import Cocoa

final class MetricRowView: NSView {
    private let titleLabel    = NSTextField(labelWithString: "")
    private let valueLabel    = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let sparkline: SparklineView?

    init(hasGraph: Bool) {
        sparkline = hasGraph ? SparklineView() : nil
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        titleLabel.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = .secondaryLabelColor

        valueLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        subtitleLabel.font = NSFont.systemFont(ofSize: 11)
        subtitleLabel.textColor = .secondaryLabelColor

        let pad: CGFloat = 16
        var allViews: [NSView] = [titleLabel, valueLabel, subtitleLabel]
        if let g = sparkline { allViews.append(g) }
        allViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        var constraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),

            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
        ]

        if let g = sparkline {
            constraints += [
                g.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
                g.leadingAnchor.constraint(equalTo: leadingAnchor, constant: pad),
                g.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -pad),
                g.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            ]
        } else {
            constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10))
        }

        NSLayoutConstraint.activate(constraints)
    }

    func configure(title: String, value: String, subtitle: String = "", color: NSColor, history: [Double] = []) {
        titleLabel.stringValue    = title
        valueLabel.stringValue    = value
        valueLabel.textColor      = color
        subtitleLabel.stringValue = subtitle
        sparkline?.update(points: history, color: color)
    }
}
