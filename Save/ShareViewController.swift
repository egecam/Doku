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
    private var sharedText: String?
    private var contentType: ContentType = .unknown
    private let logger = Logger(subsystem: "dev.egecam.Doku.Save", category: "ShareViewController")
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
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (text, error) in
                self?.handleLoadedItem(text as? String, error: error)
            }
        } else {
            logger.log("Unsupported content type")
        }
    }
    
    private func inferUrl(from text: String) -> URL? {
        let types: NSTextCheckingResult.CheckingType = .link
        let detector = try? NSDataDetector(types: types.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let match = matches?.first, let range = Range(match.range, in: text) {
            let urlString = String(text[range])
            return URL(string: urlString)
        }
        return nil
    }
    
    private func handleLoadedItem(_ item: Any?, error: Error?) {
        if let error = error {
            logger.error("Error loading item: \(error.localizedDescription)")
            return
        }
        
        Task {
            do {
                if let url = item as? URL {
                    self.logger.debug("Loaded URL: \(url.absoluteString)")
                    self.sharedUrl = url
                    self.contentType = detectContentType(url: url)
                    self.logger.debug("Detected content type for URL: \(self.contentType.rawValue)")
                    if self.contentType == .tweet {
                        // Tweet scraping logic
                    } else if self.contentType == .article {
                        self.sharedText = ""
                    }
                } else if let text = item as? String {
                    self.logger.debug("Loaded text: \(text)")
                    self.sharedText = text
                    if self.sharedUrl == nil {
                        self.sharedUrl = URL(string: "")
                        self.contentType = self.detectContentType(text: text)
                    }
                }
            }
            
            self.presentShareView()
        }
    }

    private func presentShareView() {
        let shareView = ShareView(
            url: sharedUrl,
            text: sharedText,
            contentType: contentType,
            saveAction: saveToMainApp,
            cancelAction: cancelExtension
        )
        
        let hostingController = UIHostingController(rootView: shareView)
        hostingController.modalPresentationStyle = .pageSheet
        
        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            
            sheet.delegate = self
        }
        
        present(hostingController, animated: true, completion: nil)
    }
    
    private func detectContentType(url: URL) -> ContentType {
        let urlString = url.absoluteString.lowercased()
        
        if urlString.contains("medium.com") || urlString.contains("blog") {
            return .article
        }
        
        else if urlString.contains("x.com") {
            return .tweet
        }
        
        else {
            return .article
        }
    }
    
    private func detectContentType(text: String) -> ContentType {
        // TODO: Could sophisticate the detection logic here!!
        return .passage
    }
    
    private func saveToMainApp(url: URL?, text: String?, title: String, tags: [String], contentType: ContentType) {
        let sharedDefaults = UserDefaults(suiteName: "group.RU773P5475.dev.egecam.Doku")
        let sharedKey = "SharedContent"
        let entryCountKey = "EntryCount"
        
        var sharedContent: [String: Any] = [
            "title": title,
            "tags": tags,
            "contentType": contentType.rawValue
        ]
        
        if let url = url {
            sharedContent["url"] = url.absoluteString
        }
        
        if let text = text {
            sharedContent["content"] = text
        }
        
        sharedDefaults?.set(sharedContent, forKey: sharedKey)
        
        let currentCount = sharedDefaults?.integer(forKey: entryCountKey) ?? 0
        sharedDefaults?.set(currentCount + 1, forKey: entryCountKey)
        
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    private func cancelExtension() {
        self.extensionContext?.cancelRequest(withError: NSError(domain: "dev.egecam.Doku", code: 0, userInfo: nil))
    }
}

extension ShareViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        cancelExtension()
    }
}
