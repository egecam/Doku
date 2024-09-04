//
//  DokuApp.swift
//  Doku
//
//  Created by Ege Çam on 11.07.2024.
//

import SwiftUI
import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

        }
    }()



@main
struct DokuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(\.colorScheme, .light)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                SharedContentHandler.shared.checkAndProcessSharedContent()
            }
        }
    }
}

class SharedContentHandler {
    static let shared = SharedContentHandler()
    
    private let userDefaults = UserDefaults(suiteName: "group.RU773P5475.dev.egecam.Doku")
    private let lastVisitKey = "LastVisitDate"
    private let entryCountKey = "EntryCount"
    
    private init() {}
    
    @MainActor func checkAndProcessSharedContent() {
        let sharedKey = "SharedContent"
        
        if let sharedContent = userDefaults?.object(forKey: sharedKey) as? [String: Any] {
            userDefaults?.removeObject(forKey: sharedKey)
            
            guard let title = sharedContent["title"] as? String,
                  let tags = sharedContent["tags"] as? [String],
                  let contentTypeRawValue = sharedContent["contentType"] as? String,
                  let contentType = ContentType(rawValue: contentTypeRawValue) else {
                print("Invalid shared content format")
                return
            }
            
            let url = (sharedContent["url"] as? String).flatMap { URL(string: $0) }
            let content = sharedContent["content"] as? String
            
            let homeViewModel = HomeViewModel()
            
            // Pass the URL along with other data to save the entry
            Task {
                await homeViewModel.saveEntry(url: url, content: content, title: title, tags: tags, contentType: contentType)
            }
        }
        checkForWelcomeBackNotification()
    }
    
    private func checkForWelcomeBackNotification() {
        let currentDate = Date()
        if let lastVisitDate = userDefaults?.object(forKey: lastVisitKey) as? Date {
            let calendar = Calendar.current
            if calendar.isDate(lastVisitDate, inSameDayAs: currentDate) {
                let newEntriesCount = userDefaults?.integer(forKey: entryCountKey) ?? 0
                if newEntriesCount > 0 {
                    showWelcomeBackNotification(newEntriesCount: newEntriesCount)
                }
                resetEntryCount()
            }
        }
        userDefaults?.set(currentDate, forKey: lastVisitKey)
    }
    
    private func resetEntryCount() {
        userDefaults?.set(0, forKey: entryCountKey)
    }
    
    private func showWelcomeBackNotification(newEntriesCount: Int) {
        let content = "Welcome back! You've collected \(newEntriesCount) new \(newEntriesCount == 1 ? "entry" : "entries") since your last visit."
        NotificationManager.shared.showNotification(type: .welcomeBack, content: content, showFireworks: true)
    }
}
