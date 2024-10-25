import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let safariService = SafariService()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let customTabsClientChannel = FlutterMethodChannel(
            name: "custom_tabs_client",
            binaryMessenger: controller.binaryMessenger
        )

        customTabsClientChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "warmUp":
                self?.safariService.warmUp()
                result(true)
            case "mayLaunchUrl":
                if let url = call.arguments as? String {
                    result(self?.safariService.mayLaunchUrl(url) ?? false)
                } else {
                    result(false)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
