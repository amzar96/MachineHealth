import Cocoa

final class SpecsSectionView: NSView {
    private var uptimeField:     NSTextField?
    private var battCondField:   NSTextField?
    private var battCyclesField: NSTextField?

    init(specs: MachineSpecs) {
        super.init(frame: .zero)
        setup(specs: specs)
    }

    required init?(coder: NSCoder) { nil }

    func update(snapshot: HealthSnapshot) {
        uptimeField?.stringValue = formatUptime(snapshot.uptimeSeconds)
        if let cond = snapshot.batteryCondition {
            battCondField?.stringValue = cond
        }
        if let cycles = snapshot.batteryCycleCount {
            battCyclesField?.stringValue = "\(cycles) cycles"
        }
    }

    private func setup(specs: MachineSpecs) {
        let ram = ByteCountFormatter.string(fromByteCount: Int64(specs.totalMemoryBytes), countStyle: .memory)
        let cleanChip = specs.cpuBrandString.isEmpty ? specs.modelIdentifier : specs.cpuBrandString

        let header = NSTextField(labelWithString: "SPECS")
        header.font = NSFont.systemFont(ofSize: 10, weight: .semibold)
        header.textColor = .secondaryLabelColor
        header.translatesAutoresizingMaskIntoConstraints = false
        addSubview(header)

        var allConstraints: [NSLayoutConstraint] = [
            header.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ]

        var prevBottom: NSLayoutYAxisAnchor = header.bottomAnchor
        var rowViews: [NSView] = []

        func addRow(symbol: String, label: String, value: String, field: NSTextField? = nil) {
            let (row, val) = makeRow(symbol: symbol, label: label, value: value)
            if let f = field { val.stringValue = f.stringValue }
            row.translatesAutoresizingMaskIntoConstraints = false
            addSubview(row)
            allConstraints += [
                row.topAnchor.constraint(equalTo: prevBottom, constant: rowViews.isEmpty ? 6 : 2),
                row.leadingAnchor.constraint(equalTo: leadingAnchor),
                row.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
            prevBottom = row.bottomAnchor
            rowViews.append(row)
        }

        addRow(symbol: "cpu",            label: "Chip",    value: cleanChip)
        addRow(symbol: "cpu",            label: "Cores",   value: "\(specs.physicalCores)P / \(specs.logicalCores)L")
        addRow(symbol: "memorychip",     label: "Memory",  value: ram)
        addRow(symbol: "laptopcomputer", label: "macOS",   value: specs.osVersion)

        let (uptimeRow, upField) = makeRow(symbol: "clock",           label: "Uptime",  value: "—")
        let (battRow,   batCond) = makeRow(symbol: "battery.100",     label: "Battery", value: "—")
        let (cycleRow,  batCyc)  = makeRow(symbol: "arrow.clockwise", label: "Cycles",  value: "—")

        uptimeField     = upField
        battCondField   = batCond
        battCyclesField = batCyc

        for row in [uptimeRow, battRow, cycleRow] {
            row.translatesAutoresizingMaskIntoConstraints = false
            addSubview(row)
            allConstraints += [
                row.topAnchor.constraint(equalTo: prevBottom, constant: rowViews.isEmpty ? 6 : 2),
                row.leadingAnchor.constraint(equalTo: leadingAnchor),
                row.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
            prevBottom = row.bottomAnchor
            rowViews.append(row)
        }

        if let last = rowViews.last {
            allConstraints.append(last.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10))
        }

        NSLayoutConstraint.activate(allConstraints)
    }

    private func makeRow(symbol: String, label: String, value: String) -> (NSView, NSTextField) {
        let row = NSView()

        let icon = NSImageView()
        if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) {
            img.isTemplate = true
            icon.image = img
            icon.contentTintColor = .secondaryLabelColor
        }

        let labelField = NSTextField(labelWithString: label)
        labelField.font = NSFont.systemFont(ofSize: 12)
        labelField.textColor = .secondaryLabelColor

        let valueField = NSTextField(labelWithString: value)
        valueField.font = NSFont.systemFont(ofSize: 12)
        valueField.textColor = .labelColor
        valueField.lineBreakMode = .byTruncatingTail

        [icon, labelField, valueField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview($0)
        }

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 13),
            icon.heightAnchor.constraint(equalToConstant: 13),

            labelField.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            labelField.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            labelField.widthAnchor.constraint(equalToConstant: 54),

            valueField.leadingAnchor.constraint(equalTo: labelField.trailingAnchor, constant: 6),
            valueField.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueField.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),

            row.heightAnchor.constraint(equalToConstant: 22)
        ])

        return (row, valueField)
    }

    private func formatUptime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h >= 24 { return "\(h / 24)d \(h % 24)h" }
        return "\(h)h \(m)m"
    }
}
