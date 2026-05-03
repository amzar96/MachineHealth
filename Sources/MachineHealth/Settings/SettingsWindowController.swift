import Cocoa

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    convenience init() {
        let vc = SettingsViewController()
        let window = NSWindow(contentViewController: vc)
        window.title = "Settings"
        window.styleMask = [.titled, .closable]
        window.center()
        self.init(window: window)
        window.delegate = self
    }

    func show() {
        NSApp.setActivationPolicy(.regular)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

private final class SettingsViewController: NSViewController {
    private let prefs = AppPreferences.shared

    private var intervalSlider: SliderRow!
    private var cpuWarnSlider:  SliderRow!
    private var cpuCritSlider:  SliderRow!
    private var ramWarnSlider:  SliderRow!
    private var ramCritSlider:  SliderRow!

    private var showCPUBox:     NSButton!
    private var showRAMBox:     NSButton!
    private var showDiskBox:    NSButton!
    private var showBatteryBox:    NSButton!
    private var notificationsBox:  NSButton!

    private var appearanceControl: NSSegmentedControl!

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 340, height: 100))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        view.layoutSubtreeIfNeeded()
        preferredContentSize = view.fittingSize
    }

    private func buildUI() {
        intervalSlider = SliderRow(label: "Every",    value: prefs.refreshInterval, min: 1,  max: 60,  unit: "s")
        cpuWarnSlider  = SliderRow(label: "Warning",  value: prefs.cpuWarning,      min: 10, max: 100, unit: "%")
        cpuCritSlider  = SliderRow(label: "Critical", value: prefs.cpuCritical,     min: 10, max: 100, unit: "%")
        ramWarnSlider  = SliderRow(label: "Warning",  value: prefs.ramWarning,      min: 10, max: 100, unit: "%")
        ramCritSlider  = SliderRow(label: "Critical", value: prefs.ramCritical,     min: 10, max: 100, unit: "%")

        showCPUBox     = checkbox("Show CPU",     on: prefs.showCPU)
        showRAMBox     = checkbox("Show Memory",  on: prefs.showRAM)
        showDiskBox    = checkbox("Show Disk",    on: prefs.showDisk)
        showBatteryBox   = checkbox("Show Battery",          on: prefs.showBattery)
        notificationsBox = checkbox("Enable Notifications",  on: prefs.notificationsEnabled)

        let modes = ["System", "Light", "Dark"]
        appearanceControl = NSSegmentedControl(labels: modes, trackingMode: .selectOne, target: nil, action: nil)
        let modeIndex = ["system": 0, "light": 1, "dark": 2][prefs.appearanceMode] ?? 0
        appearanceControl.selectedSegment = modeIndex

        let cancelBtn = NSButton(title: "Cancel", target: self, action: #selector(cancel))
        cancelBtn.bezelStyle = .rounded
        let saveBtn = NSButton(title: "Save", target: self, action: #selector(save))
        saveBtn.bezelStyle = .rounded
        saveBtn.keyEquivalent = "\r"

        let buttonRow = NSStackView(views: [cancelBtn, saveBtn])
        buttonRow.orientation = .horizontal
        buttonRow.spacing = 8

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        stack.addArrangedSubview(sectionLabel("Refresh Interval"))
        stack.addArrangedSubview(intervalSlider)
        stack.addArrangedSubview(spacer(4))
        stack.addArrangedSubview(sectionLabel("CPU Thresholds"))
        stack.addArrangedSubview(cpuWarnSlider)
        stack.addArrangedSubview(cpuCritSlider)
        stack.addArrangedSubview(spacer(4))
        stack.addArrangedSubview(sectionLabel("Memory Thresholds"))
        stack.addArrangedSubview(ramWarnSlider)
        stack.addArrangedSubview(ramCritSlider)
        stack.addArrangedSubview(spacer(4))
        stack.addArrangedSubview(sectionLabel("Visibility"))
        stack.addArrangedSubview(showCPUBox)
        stack.addArrangedSubview(showRAMBox)
        stack.addArrangedSubview(showDiskBox)
        stack.addArrangedSubview(showBatteryBox)
        stack.addArrangedSubview(spacer(4))
        stack.addArrangedSubview(sectionLabel("Notifications"))
        stack.addArrangedSubview(notificationsBox)
        stack.addArrangedSubview(spacer(4))
        stack.addArrangedSubview(sectionLabel("Appearance"))
        stack.addArrangedSubview(appearanceControl)
        stack.addArrangedSubview(spacer(8))
        stack.addArrangedSubview(buttonRow)

        let sliders = [intervalSlider, cpuWarnSlider, cpuCritSlider, ramWarnSlider, ramCritSlider]
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            appearanceControl.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -40)
        ] + sliders.compactMap { $0?.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -40) })
    }

    @objc private func save() {
        prefs.refreshInterval = intervalSlider.value
        prefs.cpuWarning      = cpuWarnSlider.value
        prefs.cpuCritical     = cpuCritSlider.value
        prefs.ramWarning      = ramWarnSlider.value
        prefs.ramCritical     = ramCritSlider.value
        prefs.showCPU         = showCPUBox.state     == .on
        prefs.showRAM         = showRAMBox.state     == .on
        prefs.showDisk              = showDiskBox.state       == .on
        prefs.showBattery           = showBatteryBox.state    == .on
        prefs.notificationsEnabled  = notificationsBox.state  == .on

        let modes = ["system", "light", "dark"]
        let idx = appearanceControl.selectedSegment
        prefs.appearanceMode = modes[max(0, min(2, idx))]
        prefs.applyAppearance()

        NotificationCenter.default.post(name: .preferencesChanged, object: nil)
        view.window?.close()
    }

    @objc private func cancel() {
        view.window?.close()
    }

    private func sectionLabel(_ text: String) -> NSTextField {
        let f = NSTextField(labelWithString: text)
        f.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        f.textColor = .secondaryLabelColor
        return f
    }

    private func checkbox(_ title: String, on: Bool) -> NSButton {
        let btn = NSButton(checkboxWithTitle: title, target: nil, action: nil)
        btn.state = on ? .on : .off
        return btn
    }

    private func spacer(_ h: CGFloat) -> NSView {
        let v = NSView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: h).isActive = true
        return v
    }
}

private final class SliderRow: NSView {
    private let slider: NSSlider
    private let valueLabel: NSTextField
    private let unit: String

    var value: Double { slider.doubleValue }

    init(label: String, value: Double, min: Double, max: Double, unit: String) {
        self.unit  = unit
        slider     = NSSlider(value: value, minValue: min, maxValue: max, target: nil, action: nil)
        valueLabel = NSTextField(labelWithString: "\(Int(value))\(unit)")
        super.init(frame: .zero)
        setup(label: label)
    }

    required init?(coder: NSCoder) { nil }

    private func setup(label: String) {
        let nameLabel = NSTextField(labelWithString: label)
        nameLabel.font = NSFont.systemFont(ofSize: 13)

        slider.controlSize = .small
        slider.target = self
        slider.action = #selector(sliderMoved(_:))

        valueLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        valueLabel.alignment = .right

        let row = NSStackView(views: [nameLabel, slider, valueLabel])
        row.orientation = .horizontal
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            nameLabel.widthAnchor.constraint(equalToConstant: 60),
            valueLabel.widthAnchor.constraint(equalToConstant: 36),
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func sliderMoved(_ sender: NSSlider) {
        valueLabel.stringValue = "\(Int(sender.doubleValue))\(unit)"
    }
}
