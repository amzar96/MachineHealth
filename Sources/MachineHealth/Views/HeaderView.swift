import Cocoa
import Foundation

final class HeaderView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        let icon = NSImageView()
        if let img = NSImage(systemSymbolName: "desktopcomputer", accessibilityDescription: nil) {
            icon.image = img
        }
        icon.contentTintColor = .secondaryLabelColor
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "Machine Health")
        title.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        title.textColor = .labelColor

        let machineName = Host.current().localizedName ?? "This Mac"
        let subtitle = NSTextField(labelWithString: machineName)
        subtitle.font = NSFont.systemFont(ofSize: 11)
        subtitle.textColor = .secondaryLabelColor

        let textStack = NSStackView(views: [title, subtitle])
        textStack.orientation = .vertical
        textStack.spacing = 1
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(icon)
        addSubview(textStack)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),

            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
