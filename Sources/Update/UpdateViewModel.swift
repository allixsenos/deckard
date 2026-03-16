import Foundation
import Sparkle

class UpdateViewModel: ObservableObject {
    @Published var state: UpdateState = .idle

    var text: String {
        switch state {
        case .idle:
            return ""
        case .permissionRequest:
            return "Enable Automatic Updates?"
        case .checking:
            return "Checking for Updates…"
        case .updateAvailable(let update):
            let version = update.appcastItem.displayVersionString
            if !version.isEmpty {
                return "Update Available: \(version)"
            }
            return "Update Available"
        case .downloading(let download):
            if let expectedLength = download.expectedLength, expectedLength > 0 {
                let progress = Double(download.progress) / Double(expectedLength)
                return String(format: "Downloading: %.0f%%", progress * 100)
            }
            return "Downloading…"
        case .extracting(let extracting):
            return String(format: "Preparing: %.0f%%", extracting.progress * 100)
        case .installing:
            return "Installing…"
        case .notFound:
            return "No Updates Available"
        case .error(let err):
            return err.error.localizedDescription
        }
    }
}

enum UpdateState: Equatable {
    case idle
    case permissionRequest(PermissionRequest)
    case checking(Checking)
    case updateAvailable(UpdateAvailable)
    case notFound(NotFound)
    case error(Error)
    case downloading(Downloading)
    case extracting(Extracting)
    case installing(Installing)

    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    var isInstallable: Bool {
        switch self {
        case .checking,
                .updateAvailable,
                .downloading,
                .extracting,
                .installing:
            return true
        default:
            return false
        }
    }

    func cancel() {
        switch self {
        case .checking(let checking):
            checking.cancel()
        case .updateAvailable(let available):
            available.reply(.dismiss)
        case .downloading(let downloading):
            downloading.cancel()
        case .notFound(let notFound):
            notFound.acknowledgement()
        case .error(let err):
            err.dismiss()
        default:
            break
        }
    }

    func confirm() {
        switch self {
        case .updateAvailable(let available):
            available.reply(.install)
        default:
            break
        }
    }

    static func == (lhs: UpdateState, rhs: UpdateState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.permissionRequest, .permissionRequest):
            return true
        case (.checking, .checking):
            return true
        case (.updateAvailable(let lUpdate), .updateAvailable(let rUpdate)):
            return lUpdate.appcastItem.displayVersionString == rUpdate.appcastItem.displayVersionString
        case (.notFound, .notFound):
            return true
        case (.error(let lErr), .error(let rErr)):
            return lErr.error.localizedDescription == rErr.error.localizedDescription
        case (.downloading(let lDown), .downloading(let rDown)):
            return lDown.progress == rDown.progress && lDown.expectedLength == rDown.expectedLength
        case (.extracting(let lExt), .extracting(let rExt)):
            return lExt.progress == rExt.progress
        case (.installing, .installing):
            return true
        default:
            return false
        }
    }

    struct NotFound {
        let acknowledgement: () -> Void
    }

    struct PermissionRequest {
        let request: SPUUpdatePermissionRequest
        let reply: @Sendable (SUUpdatePermissionResponse) -> Void
    }

    struct Checking {
        let cancel: () -> Void
    }

    struct UpdateAvailable {
        let appcastItem: SUAppcastItem
        let reply: @Sendable (SPUUserUpdateChoice) -> Void
    }

    struct Error {
        let error: any Swift.Error
        let retry: () -> Void
        let dismiss: () -> Void
    }

    struct Downloading {
        let cancel: () -> Void
        let expectedLength: UInt64?
        let progress: UInt64
    }

    struct Extracting {
        let progress: Double
    }

    struct Installing {
        let retryTerminatingApplication: () -> Void
        let dismiss: () -> Void
    }
}
