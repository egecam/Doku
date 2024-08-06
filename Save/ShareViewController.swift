//
//  ShareViewController.swift
//  Save
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI
import UniformTypeIdentifiers
import Firebase
import os.log
import MobileCoreServices

@objc(PrincipalClassName)

@MainActor
class ShareViewController: UIViewController {
    private var sharedUrl: URL?
    private var sharedImage: UIImage?
    private var sharedText: String?
    private var contentType: ContentType = .unknown
    private let logger = Logger()
    private var userDefaults = UserDefaults(suiteName: "group.RU773P5475.dev.egecam.Doku")
    
    override func loadView() {
        super.loadView()
        logger.log("ShareViewController loadView called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        logger.log("ShareViewController viewDidLoad called")
        
        // Check authentication status
        let isLoggedIn = userDefaults?.bool(forKey: "log_status") ?? false
        if !isLoggedIn {
            redirectToAuthentication()
            return
        }
        
        loadSharedItem()
    }
    
    private func redirectToAuthentication() {
        let alert = UIAlertController(title: "Authentication Required", message: "Please log in to use this extension.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func loadSharedItem() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            logger.log("No input items found")
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (url, error) in
                self?.handleLoadedItem(url as? URL, error: error)
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] (image, error) in
                self?.handleLoadedItem(image as? UIImage, error: error)
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (text, error) in
                self?.handleLoadedItem(text as? String, error: error)
            }
        } else {
            logger.log("Unsupported content type")
        }
    }
    
    private func handleLoadedItem(_ item: Any?, error: Error?) {
        if let error = error {
            logger.error("Error loading item: \(error.localizedDescription)")
            return
        }
        
        DispatchQueue.main.async {
            if let url = item as? URL {
                self.logger.log("Loaded URL: \(url.absoluteString)")
                self.sharedUrl = url
                self.contentType = self.detectContentType(url: url)
                self.logger.log("Detected content type for URL: \(self.contentType.rawValue)")
            } else if let image = item as? UIImage {
                self.logger.log("Loaded image")
                self.sharedImage = image
                self.contentType = .image
            } else if let text = item as? String {
                self.logger.log("Loaded text: \(text)")
                self.sharedText = text
                self.contentType = self.detectContentType(text: text)
            }
            
            self.presentShareView()
        }
    }
    
    private func presentShareView() {
        let shareView = ShareView(
            url: sharedUrl,
            image: sharedImage,
            text: sharedText,
            contentType: contentType,
            saveAction: saveToMainApp
        )
        
        let hostingController = UIHostingController(rootView: shareView.presentationDetents([.medium]))
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }
    
    private func detectContentType(url: URL) -> ContentType {
        let urlString = url.absoluteString.lowercased()
        
        if urlString.contains("medium.com") || urlString.contains("blog") {
            return .article
        }
        
        if urlString.contains("twitter.com") || urlString.contains("x.com") {
            return .tweet
        }
        
        let imageExtensions = ["jpg", "jpeg", "png", "gif"]
        if imageExtensions.contains(url.pathExtension.lowercased()) {
            return .image
        }
        
        return .article
    }
    
    private func detectContentType(text: String) -> ContentType {
        // TODO: Could sophisticate the detection logic here!!
        return .passage
    }
    
    private func saveToMainApp(url: URL?, image: UIImage?, text: String?, title: String, tags: [String], contentType: ContentType) {
        let sharedDefaults = UserDefaults(suiteName: "group.RU773P5475.dev.egecam.Doku")
        let sharedKey = "SharedContent"
        
        var sharedContent: [String: Any] = [
            "title": title,
            "tags": tags,
            "contentType": contentType.rawValue
        ]
        
        if let url = url {
            sharedContent["url"] = url.absoluteString
        }
        
        if let image = image {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                sharedContent["imageData"] = imageData
            }
        }
        
        if let text = text {
            sharedContent["content"] = text
        }
        
        sharedDefaults?.set(sharedContent, forKey: sharedKey)
        
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
