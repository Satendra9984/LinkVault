import SafariServices
import Flutter

class SafariService: NSObject {
    private var safariViewController: SFSafariViewController?
    private var preloadedURL: URL?

    func warmUp() {
        // Preload an empty page as a warm-up if necessary
        preloadedURL = URL(string: "about:blank")
    }

    func mayLaunchUrl(_ url: String) -> Bool {
        guard let url = URL(string: url) else {
            return false
        }
        preloadedURL = url
        return true
    }

    func openSafariViewController(from viewController: UIViewController) {
        guard let url = preloadedURL else { return }
        safariViewController = SFSafariViewController(url: url)
        viewController.present(safariViewController!, animated: true)
    }
}
