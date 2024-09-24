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
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    var secondaryWindow: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            setupSecondaryOverlayWindow(in: windowScene)
        }
    }
    
    func setupSecondaryOverlayWindow(in scene: UIWindowScene) {
        let secondaryViewController = UIHostingController(
            rootView:
                EmptyView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(InAppNotificationViewModifier())
        )
        secondaryViewController.view.backgroundColor = .clear
        let secondaryWindow = PassThroughWindow(windowScene: scene)
        secondaryWindow.rootViewController = secondaryViewController
        secondaryWindow.isHidden = false
        self.secondaryWindow = secondaryWindow
    }
}

class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint,
                          with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event)
        else { return nil }
        
        return rootViewController?.view == hitView ? nil : hitView
    }
}

@main
struct DokuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        loadRocketSimConnect()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modifier(InAppNotificationViewModifier())
            
        }
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

private func loadRocketSimConnect() {
#if DEBUG
    guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
        print("Failed to load linker framework")
        return
    }
    print("RocketSim Connect successfully linked")
#endif
}
