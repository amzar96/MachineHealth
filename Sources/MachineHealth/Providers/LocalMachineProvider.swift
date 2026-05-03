import Darwin
import Foundation

final class LocalMachineProvider: MachineProvider {
    let specs: MachineSpecs
    private let cpu     = CPUSampler()
    private let memory  = MemorySampler()
    private let disk    = DiskSampler()
    private let battery = BatterySampler()

    init() {
        specs = SpecsLoader.load()
    }

    func fetchHealthSnapshot() -> HealthSnapshot {
        let mem = memory.sample()
        let dsk = disk.sample()
        let bat = battery.sample()

        var tv = timeval()
        var sz = MemoryLayout<timeval>.size
        sysctlbyname("kern.boottime", &tv, &sz, nil, 0)
        let uptime = Int(Date().timeIntervalSince1970) - Int(tv.tv_sec)

        return HealthSnapshot(
            cpuPercent:                cpu.sample(),
            memUsedBytes:              mem.used,
            memTotalBytes:             mem.total,
            diskUsedBytes:             dsk.used,
            diskTotalBytes:            dsk.total,
            batteryPercent:            bat?.percent,
            isCharging:                bat?.isCharging,
            batteryCondition:          bat?.condition,
            batteryCycleCount:         bat?.cycleCount,
            batteryTimeRemainingMinutes: bat?.timeRemainingMinutes,
            uptimeSeconds:             max(0, uptime),
            sampledAt:                 Date()
        )
    }
}
