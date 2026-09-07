import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        if let url = launchOptions?[.url] as? URL {
            handleSharedImage(url: url)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if url.scheme == "savedcontentgraveyard" && url.host == "shared" {
            handleSharedImageFromDefaults()
            return true
        }
        return super.application(app, open: url, options: options)
    }
    
    private func handleSharedImage(url: URL) {
        let fileManager = FileManager.default
        if let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.savedcontentgraveyard.share"
        ) {
            let imagePath = containerURL.appendingPathComponent("shared_image.jpg").path
            if fileManager.fileExists(atPath: imagePath) {
                NotificationCenter.default.post(
                    name: .sharedImageReceived,
                    object: nil,
                    userInfo: ["imagePath": imagePath]
                )
            }
        }
    }
    
    private func handleSharedImageFromDefaults() {
        let userDefaults = UserDefaults(suiteName: "group.com.savedcontentgraveyard.share")
        if let imagePath = userDefaults?.string(forKey: "shared_image_path") {
            NotificationCenter.default.post(
                name: .sharedImageReceived,
                object: nil,
                userInfo: ["imagePath": imagePath]
            )
            userDefaults?.removeObject(forKey: "shared_image_path")
        }
    }
}

extension Notification.Name {
    static let sharedImageReceived = Notification.Name("sharedImageReceived")
}
