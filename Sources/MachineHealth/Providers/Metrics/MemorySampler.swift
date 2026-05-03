import Darwin
import Foundation

struct MemorySampler {
    func sample() -> (used: UInt64, total: UInt64) {
        var info = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return (0, 0) }
        let page = UInt64(vm_page_size)
        let used = (UInt64(info.active_count) + UInt64(info.inactive_count) +
                    UInt64(info.wire_count) + UInt64(info.compressor_page_count)) * page
        let total = ProcessInfo.processInfo.physicalMemory
        return (used, total)
    }
}
