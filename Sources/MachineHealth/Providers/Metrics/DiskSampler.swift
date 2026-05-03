import Foundation

struct DiskSampler {
    func sample() -> (used: Int64, total: Int64) {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: "/"),
              let total = attrs[.systemSize] as? Int64,
              let free  = attrs[.systemFreeSize] as? Int64 else {
            return (0, 0)
        }
        return (total - free, total)
    }
}
