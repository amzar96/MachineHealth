import Cocoa

final class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popoverController: PopoverController
    private var settingsWC: SettingsWindowController?
    private let onRefresh: () -> Void

    init(specs: MachineSpecs, onRefresh: @escaping () -> Void) {
        self.popoverController = PopoverController(specs: specs)
        self.onRefresh = onRefresh
        setupButton()
    }

    private func setupButton() {
        guard let button = statusItem.button else { return }
        if let img = NSImage(systemSymbolName: "desktopcomputer", accessibilityDescription: nil) {
            img.isTemplate = true
            button.image = img
        }
        button.action = #selector(handleClick(_:))
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showContextMenu(for: sender)
        } else {
            popoverController.toggle(relativeTo: sender)
        }
    }

    private func showContextMenu(for button: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        let menu = NSMenu()

        let refresh = NSMenuItem(title: "Refresh Now", action: #selector(doRefresh), keyEquivalent: "r")
        refresh.target = self
        menu.addItem(refresh)

        let settings = NSMenuItem(title: "Settings…", action: #selector(doSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        menu.addItem(.separator())

        let about = NSMenuItem(title: "About MachineHealth", action: #selector(doAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quit.target = NSApplication.shared
        menu.addItem(quit)

        NSMenu.popUpContextMenu(menu, with: event, for: button)
    }

    @objc private func doRefresh()  { onRefresh() }

    @objc private func doSettings() {
        if settingsWC == nil { settingsWC = SettingsWindowController() }
        settingsWC?.show()
    }

    @objc private func doAbout() {
        let alert = NSAlert()
        alert.messageText     = "MachineHealth"
        alert.informativeText = "macOS machine health monitor\n\nVersion 1.0\nBuilt with Swift + AppKit"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func update(with snapshot: HealthSnapshot) {
        popoverController.update(with: snapshot)
    }
}
