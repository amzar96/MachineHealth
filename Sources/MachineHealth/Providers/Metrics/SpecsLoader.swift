import Darwin
import Foundation

struct SpecsLoader {
    static func load() -> MachineSpecs {
        let ver = ProcessInfo.processInfo.operatingSystemVersion
        let osVersion = "macOS \(ver.majorVersion).\(ver.minorVersion).\(ver.patchVersion)"
        return MachineSpecs(
            modelIdentifier:  string("hw.model") ?? "Unknown",
            cpuBrandString:   string("machdep.cpu.brand_string") ?? string("hw.model") ?? "Unknown",
            physicalCores:    int32("hw.physicalcpu").map(Int.init) ?? 0,
            logicalCores:     int32("hw.logicalcpu").map(Int.init) ?? 0,
            totalMemoryBytes: ProcessInfo.processInfo.physicalMemory,
            osVersion:        osVersion
        )
    }

    private static func string(_ key: String) -> String? {
        var size = 0
        guard sysctlbyname(key, nil, &size, nil, 0) == 0, size > 0 else { return nil }
        var buf = [CChar](repeating: 0, count: size)
        sysctlbyname(key, &buf, &size, nil, 0)
        return String(cString: buf)
    }

    private static func int32(_ key: String) -> Int32? {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        guard sysctlbyname(key, &value, &size, nil, 0) == 0 else { return nil }
        return value
    }
}
