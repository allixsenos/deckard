import Sparkle
import AppKit

extension UpdateDriver: SPUUpdaterDelegate {
    func feedURLString(for updater: SPUUpdater) -> String? {
        // Appcast hosted alongside GitHub Releases via GitHub Pages.
        return "https://deckard-app.github.io/releases/appcast.xml"
    }

    func updater(_ updater: SPUUpdater, willInstallUpdateOnQuit item: SUAppcastItem, immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) -> Bool {
        viewModel.state = .installing(.init(
            retryTerminatingApplication: immediateInstallHandler,
            dismiss: { [weak viewModel] in
                viewModel?.state = .idle
            }
        ))
        return true
    }

    func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
        NSApp.invalidateRestorableState()
        for window in NSApp.windows { window.invalidateRestorableState() }
    }
}
