import Foundation

final class HistoryBuffer {
    private var data: [Double]
    private var head = 0
    private var count = 0
    let capacity: Int

    init(capacity: Int = 60) {
        self.capacity = capacity
        data = [Double](repeating: 0, count: capacity)
    }

    func append(_ value: Double) {
        if count == 0 {
            data = [Double](repeating: value, count: capacity)
            count = capacity
            head = 0
        }
        data[head] = value
        head = (head + 1) % capacity
    }

    var values: [Double] {
        guard count > 0 else { return [] }
        if count < capacity { return Array(data[0..<count]) }
        return Array(data[head...] + data[..<head])
    }
}
