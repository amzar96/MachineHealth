import Foundation

struct HealthSnapshot {
    let cpuPercent: Double
    let memUsedBytes: UInt64
    let memTotalBytes: UInt64
    let diskUsedBytes: Int64
    let diskTotalBytes: Int64
    let batteryPercent: Int?
    let isCharging: Bool?
    let batteryCondition: String?
    let batteryCycleCount: Int?
    let batteryTimeRemainingMinutes: Int?
    let uptimeSeconds: Int
    let sampledAt: Date
}
