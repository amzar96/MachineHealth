import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var refreshLoop: RefreshLoop?
    private var provider: LocalMachineProvider?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppPreferences.shared.applyAppearance()
        NotificationManager.shared.requestAuthorization()

        let prov = LocalMachineProvider()
        provider = prov

        statusBarController = StatusBarController(specs: prov.specs) { [weak self] in
            self?.manualRefresh()
        }

        startLoop(provider: prov)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesChanged),
            name: .preferencesChanged,
            object: nil
        )
    }

    @objc private func preferencesChanged() {
        AppPreferences.shared.applyAppearance()
        guard let prov = provider else { return }
        startLoop(provider: prov)
    }

    private func startLoop(provider: LocalMachineProvider) {
        refreshLoop?.stop()
        refreshLoop = RefreshLoop(provider: provider) { [weak self] snapshot in
            self?.statusBarController?.update(with: snapshot)
            NotificationManager.shared.check(snapshot: snapshot)
        }
        refreshLoop?.start(interval: AppPreferences.shared.refreshInterval)
    }

    private func manualRefresh() {
        guard let prov = provider else { return }
        let snapshot = prov.fetchHealthSnapshot()
        statusBarController?.update(with: snapshot)
        NotificationManager.shared.check(snapshot: snapshot)
    }
}
