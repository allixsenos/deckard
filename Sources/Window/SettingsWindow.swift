import AppKit

class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Deckard Settings"
        window.center()

        // Set app icon in the window
        if let iconPath = Bundle.main.resourceURL?.appendingPathComponent("AppIcon.icns").path,
           let icon = NSImage(contentsOfFile: iconPath) {
            window.representedURL = URL(fileURLWithPath: "/")
            window.standardWindowButton(.documentIconButton)?.image = icon
        }

        super.init(window: window)
        setupContent()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupContent() {
        guard let contentView = window?.contentView else { return }
        contentView.wantsLayer = true

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        contentView.addSubview(scrollView)

        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = container

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        var yOffset: CGFloat = 20

        // --- Section: Claude Code ---
        yOffset = addSectionHeader("Claude Code", to: container, at: yOffset)
        yOffset = addTextField(
            label: "Extra arguments",
            key: "claudeExtraArgs",
            placeholder: "--dangerously-skip-permissions",
            help: "Arguments passed to every new Claude Code session.\nExample: --dangerously-skip-permissions",
            to: container, at: yOffset
        )

        // --- Section: Default Tabs ---
        yOffset = addSectionHeader("Default Project Tabs", to: container, at: yOffset)
        yOffset = addTextField(
            label: "Tab configuration",
            key: "defaultTabConfig",
            placeholder: "claude, terminal",
            help: "Comma-separated list of tabs created when opening a new project.\nValues: claude, terminal\nDefault: claude, terminal",
            to: container, at: yOffset
        )

        // Set initial value if not set
        if UserDefaults.standard.string(forKey: "defaultTabConfig") == nil {
            UserDefaults.standard.set("claude, terminal", forKey: "defaultTabConfig")
        }

        // --- Section: About ---
        yOffset = addSectionHeader("About", to: container, at: yOffset)
        yOffset = addAboutSection(to: container, at: yOffset)

        // Set container height
        container.heightAnchor.constraint(equalToConstant: yOffset + 20).isActive = true
    }

    private func addSectionHeader(_ title: String, to container: NSView, at y: CGFloat) -> CGFloat {
        let label = NSTextField(labelWithString: title)
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separator)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: y),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            separator.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        ])

        return y + 30
    }

    private func addTextField(label: String, key: String, placeholder: String, help: String,
                               to container: NSView, at y: CGFloat) -> CGFloat {
        let titleLabel = NSTextField(labelWithString: label)
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .secondaryLabelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        let field = NSTextField()
        field.stringValue = UserDefaults.standard.string(forKey: key) ?? ""
        field.placeholderString = placeholder
        field.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.target = self
        field.tag = key.hashValue
        container.addSubview(field)

        // Store key for later retrieval
        objc_setAssociatedObject(field, &settingsKeyAssoc, key, .OBJC_ASSOCIATION_RETAIN)
        field.action = #selector(textFieldChanged(_:))

        let helpLabel = NSTextField(wrappingLabelWithString: help)
        helpLabel.font = .systemFont(ofSize: 10)
        helpLabel.textColor = .tertiaryLabelColor
        helpLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(helpLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: y),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            field.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            field.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            field.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            helpLabel.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 4),
            helpLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            helpLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
        ])

        return y + 80
    }

    private func addAboutSection(to container: NSView, at y: CGFloat) -> CGFloat {
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 12
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        // App icon
        if let iconPath = Bundle.main.resourceURL?.appendingPathComponent("AppIcon.icns").path,
           let icon = NSImage(contentsOfFile: iconPath) {
            let imageView = NSImageView(image: icon)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 48),
                imageView.heightAnchor.constraint(equalToConstant: 48),
            ])
            stack.addArrangedSubview(imageView)
        }

        let textStack = NSStackView()
        textStack.orientation = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2

        let nameLabel = NSTextField(labelWithString: "Deckard")
        nameLabel.font = .boldSystemFont(ofSize: 13)
        textStack.addArrangedSubview(nameLabel)

        let versionLabel = NSTextField(labelWithString: "Version 0.1.0")
        versionLabel.font = .systemFont(ofSize: 11)
        versionLabel.textColor = .secondaryLabelColor
        textStack.addArrangedSubview(versionLabel)

        let descLabel = NSTextField(labelWithString: "Multi-session Claude Code terminal manager")
        descLabel.font = .systemFont(ofSize: 11)
        descLabel.textColor = .tertiaryLabelColor
        textStack.addArrangedSubview(descLabel)

        stack.addArrangedSubview(textStack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: y),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
        ])

        return y + 70
    }

    @objc private func textFieldChanged(_ sender: NSTextField) {
        guard let key = objc_getAssociatedObject(sender, &settingsKeyAssoc) as? String else { return }
        UserDefaults.standard.set(sender.stringValue, forKey: key)
    }

    func show() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private var settingsKeyAssoc: UInt8 = 0
