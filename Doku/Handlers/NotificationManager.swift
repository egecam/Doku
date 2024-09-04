//
//  NotificationManager.swift
//  Doku
//
//  Created by Ege Çam on 30.08.2024.
//

import Foundation

enum NotificationType {
    case favourite
    case unfavourite
    case delete
    case welcomeBack
}

struct NotificationData {
    let type: NotificationType
    let content: String
    let showFireworks: Bool
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var currentNotification: NotificationData?
    @Published var isShowingNotification = false
    
    private init() {}
    
    func showNotification(type: NotificationType, content: String, showFireworks: Bool = false) {
        currentNotification = NotificationData(type: type, content: content, showFireworks: showFireworks)
        isShowingNotification = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideNotification()
        }
    }
    
    func hideNotification() {
        isShowingNotification = false
        currentNotification = nil
    }
}
