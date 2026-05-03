import AppKit

final class AppPreferences {
    static let shared = AppPreferences()

    var cpuWarning:      Double       { get { num("cpuWarn")    ?? 70  } set { save("cpuWarn",    newValue) } }
    var cpuCritical:     Double       { get { num("cpuCrit")    ?? 90  } set { save("cpuCrit",    newValue) } }
    var ramWarning:      Double       { get { num("ramWarn")    ?? 70  } set { save("ramWarn",    newValue) } }
    var ramCritical:     Double       { get { num("ramCrit")    ?? 90  } set { save("ramCrit",    newValue) } }
    var refreshInterval: TimeInterval { get { num("interval")   ?? 5   } set { save("interval",   newValue) } }

    var showCPU:     Bool { get { flag("showCPU")     ?? true  } set { save("showCPU",     newValue) } }
    var showRAM:     Bool { get { flag("showRAM")     ?? true  } set { save("showRAM",     newValue) } }
    var showDisk:    Bool { get { flag("showDisk")    ?? true  } set { save("showDisk",    newValue) } }
    var showBattery:           Bool { get { flag("showBattery")           ?? true  } set { save("showBattery",           newValue) } }
    var notificationsEnabled:  Bool { get { flag("notificationsEnabled")  ?? true  } set { save("notificationsEnabled",  newValue) } }

    var appearanceMode: String {
        get { UserDefaults.standard.string(forKey: "appearanceMode") ?? "system" }
        set { UserDefaults.standard.set(newValue, forKey: "appearanceMode") }
    }

    func applyAppearance() {
        switch appearanceMode {
        case "light": NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":  NSApp.appearance = NSAppearance(named: .darkAqua)
        default:      NSApp.appearance = nil
        }
    }

    func color(for value: Double, warning: Double, critical: Double) -> NSColor {
        if value >= critical { return .systemRed }
        if value >= warning  { return .systemOrange }
        return .systemGreen
    }

    func batteryColor(for percent: Int) -> NSColor {
        if percent <= 10 { return .systemRed }
        if percent <= 20 { return .systemOrange }
        return .systemGreen
    }

    private func num(_ key: String) -> Double? {
        let v = UserDefaults.standard.double(forKey: key)
        return v > 0 ? v : nil
    }

    private func flag(_ key: String) -> Bool? {
        guard UserDefaults.standard.object(forKey: key) != nil else { return nil }
        return UserDefaults.standard.bool(forKey: key)
    }

    private func save(_ key: String, _ value: Double) { UserDefaults.standard.set(value, forKey: key) }
    private func save(_ key: String, _ value: Bool)   { UserDefaults.standard.set(value, forKey: key) }
}

extension Notification.Name {
    static let preferencesChanged = Notification.Name("com.personal.MachineHealth.preferencesChanged")
}
