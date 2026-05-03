import Foundation
import IOKit

struct BatterySample {
    let percent: Int
    let isCharging: Bool
    let isCharged: Bool
    let condition: String
    let cycleCount: Int
    let timeRemainingMinutes: Int
}

struct BatterySampler {
    func sample() -> BatterySample? {
        let service = IOServiceGetMatchingService(
            mach_port_t(0),
            IOServiceMatching("AppleSmartBattery")
        )
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }

        var propsRef: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &propsRef, kCFAllocatorDefault, 0) == kIOReturnSuccess,
              let props = propsRef?.takeRetainedValue() as? [String: Any] else { return nil }

        let current   = props["CurrentCapacity"] as? Int ?? 0
        let max       = props["MaxCapacity"] as? Int ?? 100
        let pct       = max > 0 ? min(100, current * 100 / max) : 0
        let charging  = props["IsCharging"] as? Bool ?? false
        let charged   = props["FullyCharged"] as? Bool ?? false
        let condition = props["BatteryHealthCondition"] as? String ?? "Normal"
        let cycles    = props["CycleCount"] as? Int ?? 0
        let remaining = props["TimeRemaining"] as? Int ?? -1

        return BatterySample(
            percent: pct,
            isCharging: charging,
            isCharged: charged,
            condition: condition,
            cycleCount: cycles,
            timeRemainingMinutes: remaining
        )
    }
}
