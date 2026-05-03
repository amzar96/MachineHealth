import Cocoa

final class PopoverController {
    private let popover = NSPopover()
    private let contentVC: PopoverViewController

    init(specs: MachineSpecs) {
        contentVC = PopoverViewController(specs: specs)
        popover.contentViewController = contentVC
        popover.behavior = .transient
        popover.animates = true
        applyAppearance()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesChanged),
            name: .preferencesChanged,
            object: nil
        )
    }

    @objc private func preferencesChanged() {
        applyAppearance()
    }

    private func applyAppearance() {
        switch AppPreferences.shared.appearanceMode {
        case "light": popover.appearance = NSAppearance(named: .aqua)
        case "dark":  popover.appearance = NSAppearance(named: .darkAqua)
        default:      popover.appearance = nil
        }
    }

    func toggle(relativeTo button: NSView) {
        if popover.isShown {
            popover.close()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func close() { popover.close() }

    func update(with snapshot: HealthSnapshot) {
        contentVC.update(with: snapshot)
    }
}
