import AppKit
import UserNotifications
import Foundation

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private var wasAbove: [String: Bool] = [:]

    private var hasBundle: Bool {
        Bundle.main.bundleIdentifier != nil
    }

    func requestAuthorization() {
        guard hasBundle else { return }
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if !granted {
                DispatchQueue.main.async {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!)
                }
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handler([.banner, .sound])
    }

    func check(snapshot: HealthSnapshot) {
        let prefs = AppPreferences.shared

        fire(key: "cpu",
             title:    "High CPU Usage",
             subtitle: "Machine Health",
             body:     String(format: "CPU is at %.1f%%", snapshot.cpuPercent),
             symbol:   "cpu",
             tint:     .systemRed,
             value:    snapshot.cpuPercent,
             threshold: prefs.cpuCritical)

        let memPct = snapshot.memTotalBytes > 0
            ? Double(snapshot.memUsedBytes) / Double(snapshot.memTotalBytes) * 100
            : 0.0
        fire(key: "memory",
             title:    "High Memory Usage",
             subtitle: "Machine Health",
             body:     String(format: "Memory is at %.1f%%", memPct),
             symbol:   "memorychip",
             tint:     .systemRed,
             value:    memPct,
             threshold: prefs.ramCritical)

        let diskPct = snapshot.diskTotalBytes > 0
            ? Double(snapshot.diskUsedBytes) / Double(snapshot.diskTotalBytes) * 100
            : 0.0
        fire(key: "disk",
             title:    "Low Disk Space",
             subtitle: "Machine Health",
             body:     String(format: "Disk usage is at %.1f%%", diskPct),
             symbol:   "internaldrive",
             tint:     .systemOrange,
             value:    diskPct,
             threshold: 90)

        if let pct = snapshot.batteryPercent, snapshot.isCharging == false {
            fire(key: "battery",
                 title:    "Low Battery",
                 subtitle: "Machine Health",
                 body:     "Battery is at \(pct)% — connect power",
                 symbol:   "battery.25",
                 tint:     .systemRed,
                 value:    Double(100 - pct),
                 threshold: 80)
        }
    }

    private func fire(key: String, title: String, subtitle: String, body: String, symbol: String, tint: NSColor, value: Double, threshold: Double) {
        let isAbove = value >= threshold
        let was = wasAbove[key] ?? false
        wasAbove[key] = isAbove
        guard isAbove && !was, AppPreferences.shared.notificationsEnabled else { return }

        if hasBundle {
            let content = UNMutableNotificationContent()
            content.title    = title
            content.subtitle = subtitle
            content.body     = body
            content.sound    = .default
            let id  = "\(key)-\(Int(Date().timeIntervalSince1970))"
            let req = UNNotificationRequest(identifier: id, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(req) { _ in }
        } else {
            ToastNotification.show(title: title, body: body, symbol: symbol, tint: tint)
        }
    }
}
