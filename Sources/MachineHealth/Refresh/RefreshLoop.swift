import Foundation

final class RefreshLoop {
    private var timer: Timer?
    private let provider: MachineProvider
    private let onUpdate: (HealthSnapshot) -> Void

    init(provider: MachineProvider, onUpdate: @escaping (HealthSnapshot) -> Void) {
        self.provider = provider
        self.onUpdate = onUpdate
    }

    func start(interval: TimeInterval = 5) {
        stop()
        onUpdate(provider.fetchHealthSnapshot())
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.onUpdate(self.provider.fetchHealthSnapshot())
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
