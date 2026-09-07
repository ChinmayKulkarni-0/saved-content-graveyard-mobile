import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    let imageKey = "shared_image_path"
    let userDefaults = UserDefaults(suiteName: "group.com.savedcontentgraveyard.share")
    
    override func isContentValid() -> Bool {
        return true
    }
    
    override func didSelectPost() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completeRequest()
            return
        }
        
        var imageFound = false
        
        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypeImage as String) { [weak self] item, error in
                        guard let self = self else { return }
                        
                        if let imageUrl = item as? URL {
                            self.handleImage(url: imageUrl)
                            imageFound = true
                        } else if let imageData = item as? Data {
                            self.handleImageData(imageData)
                            imageFound = true
                        }
                        
                        if imageFound {
                            self.completeRequest()
                        }
                    }
                    return
                }
            }
        }
        
        if !imageFound {
            completeRequest()
        }
    }
    
    private func handleImage(url: URL) {
        let fileManager = FileManager.default
        let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.savedcontentgraveyard.share"
        )
        
        guard let container = containerURL else { return }
        
        let fileName = "shared_image_\(Date().timeIntervalSince1970).jpg"
        let destinationURL = container.appendingPathComponent(fileName)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: url, to: destinationURL)
            
            userDefaults?.set(destinationURL.path, forKey: imageKey)
            userDefaults?.synchronize()
            
            openMainApp()
        } catch {
            print("Error copying image: \(error)")
        }
    }
    
    private func handleImageData(_ imageData: Data) {
        let fileManager = FileManager.default
        let containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.savedcontentgraveyard.share"
        )
        
        guard let container = containerURL else { return }
        
        let fileName = "shared_image_\(Date().timeIntervalSince1970).jpg"
        let destinationURL = container.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: destinationURL)
            
            userDefaults?.set(destinationURL.path, forKey: imageKey)
            userDefaults?.synchronize()
            
            openMainApp()
        } catch {
            print("Error writing image data: \(error)")
        }
    }
    
    private func openMainApp() {
        var responder = self as UIResponder?
        let selector = NSSelectorFromString("openURL:")
        
        while responder != nil {
            if responder!.responds(to: selector) {
                responder!.perform(selector, with: URL(string: "savedcontentgraveyard://shared")!)
                break
            }
            responder = responder?.next
        }
        
        completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        return []
    }
}
