import Cocoa

final class PopoverViewController: NSViewController {
    private let cpuRow     = MetricRowView(hasGraph: true)
    private let ramRow     = MetricRowView(hasGraph: true)
    private let diskRow    = MetricRowView(hasGraph: false)
    private let batteryRow = MetricRowView(hasGraph: false)
    private let specsSection: SpecsSectionView

    private var cpuSection:     NSView?
    private var ramSection:     NSView?
    private var diskSection:    NSView?
    private var batterySection: NSView?
    private var leftStack:      NSStackView?

    private let cpuHistory = HistoryBuffer()
    private let ramHistory = HistoryBuffer()
    private let prefs      = AppPreferences.shared

    private static let totalWidth: CGFloat  = 520
    private static let leftWidth:  CGFloat  = 300

    init(specs: MachineSpecs) {
        specsSection = SpecsSectionView(specs: specs)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0,
                                   width: Self.totalWidth, height: 420))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshSections),
            name: .preferencesChanged,
            object: nil
        )
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        let h = view.fittingSize.height
        if h > 0 { preferredContentSize = NSSize(width: Self.totalWidth, height: h) }
    }

    private func buildLayout() {
        let header = HeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let hSep = makeSep()
        view.addSubview(hSep)

        cpuSection     = wrap(cpuRow)
        ramSection     = wrap(ramRow)
        diskSection    = wrap(diskRow)
        batterySection = wrap(batteryRow)

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        leftStack = stack

        [cpuSection, ramSection, diskSection, batterySection].compactMap { $0 }.forEach { s in
            stack.addArrangedSubview(s)
            stack.addConstraint(s.widthAnchor.constraint(equalTo: stack.widthAnchor))
        }
        view.addSubview(stack)

        let vSep = makeSep()
        view.addSubview(vSep)

        specsSection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(specsSection)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            hSep.topAnchor.constraint(equalTo: header.bottomAnchor),
            hSep.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hSep.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hSep.heightAnchor.constraint(equalToConstant: 1),

            stack.topAnchor.constraint(equalTo: hSep.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.widthAnchor.constraint(equalToConstant: Self.leftWidth),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            vSep.topAnchor.constraint(equalTo: hSep.bottomAnchor),
            vSep.leadingAnchor.constraint(equalTo: stack.trailingAnchor),
            vSep.widthAnchor.constraint(equalToConstant: 1),
            vSep.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            specsSection.topAnchor.constraint(equalTo: hSep.bottomAnchor),
            specsSection.leadingAnchor.constraint(equalTo: vSep.trailingAnchor),
            specsSection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            specsSection.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])

        refreshSections()
    }

    private func wrap(_ content: NSView) -> NSView {
        let wrapper = NSView()
        let sep = makeSep()
        content.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(sep)
        wrapper.addSubview(content)
        NSLayoutConstraint.activate([
            sep.topAnchor.constraint(equalTo: wrapper.topAnchor),
            sep.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 1),
            content.topAnchor.constraint(equalTo: sep.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
        ])
        return wrapper
    }

    private func makeSep() -> NSBox {
        let sep = NSBox()
        sep.boxType = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        return sep
    }

    @objc private func refreshSections() {
        cpuSection?.isHidden     = !prefs.showCPU
        ramSection?.isHidden     = !prefs.showRAM
        diskSection?.isHidden    = !prefs.showDisk
        batterySection?.isHidden = !prefs.showBattery
    }

    func update(with snapshot: HealthSnapshot) {
        cpuHistory.append(snapshot.cpuPercent)

        let memPct = snapshot.memTotalBytes > 0
            ? Double(snapshot.memUsedBytes) / Double(snapshot.memTotalBytes) * 100 : 0.0
        ramHistory.append(memPct)

        let diskPct = snapshot.diskTotalBytes > 0
            ? Double(snapshot.diskUsedBytes) / Double(snapshot.diskTotalBytes) * 100 : 0.0

        let cpuColor  = prefs.color(for: snapshot.cpuPercent, warning: prefs.cpuWarning,  critical: prefs.cpuCritical)
        let ramColor  = prefs.color(for: memPct,              warning: prefs.ramWarning,  critical: prefs.ramCritical)
        let diskColor = prefs.color(for: diskPct,             warning: 80,                critical: 95)

        let freeBytes = Int64(max(0, snapshot.diskTotalBytes)) - Int64(max(0, snapshot.diskUsedBytes))

        cpuRow.configure(
            title: "CPU", value: String(format: "%.1f%%", snapshot.cpuPercent),
            color: cpuColor, history: cpuHistory.values)
        ramRow.configure(
            title: "MEMORY", value: "\(Int(memPct))%",
            subtitle: "\(fmt(snapshot.memUsedBytes, .memory)) / \(fmt(snapshot.memTotalBytes, .memory))",
            color: ramColor, history: ramHistory.values)
        diskRow.configure(
            title: "DISK", value: "\(Int(diskPct))%",
            subtitle: "Used \(fmt(UInt64(max(0, snapshot.diskUsedBytes)), .file))  ·  Free \(fmt(UInt64(max(0, freeBytes)), .file))",
            color: diskColor)

        if let pct = snapshot.batteryPercent {
            batteryRow.configure(
                title: "BATTERY", value: "\(pct)%",
                subtitle: batterySubtitle(snapshot: snapshot),
                color: prefs.batteryColor(for: pct))
            batterySection?.isHidden = !prefs.showBattery
        } else {
            batterySection?.isHidden = true
        }

        specsSection.update(snapshot: snapshot)
    }

    private func batterySubtitle(snapshot: HealthSnapshot) -> String {
        guard let charging = snapshot.isCharging else { return "" }
        if charging {
            if let m = snapshot.batteryTimeRemainingMinutes, m > 0 {
                return "Charging · \(m / 60)h \(m % 60)m to full"
            }
            return "Charging"
        }
        if let pct = snapshot.batteryPercent, pct >= 99 { return "Full" }
        if let m = snapshot.batteryTimeRemainingMinutes, m > 0 {
            return "\(m / 60)h \(m % 60)m remaining"
        }
        return "On battery"
    }

    private func fmt(_ n: UInt64, _ style: ByteCountFormatter.CountStyle) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(n), countStyle: style)
    }
}
