//
//  AuthManager.swift
//  Doku
//
//  Created by Ege Çam on 24.07.2024.
//

import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    
    private let userDefaults: UserDefaults?
    
    init() {
        userDefaults = UserDefaults(suiteName: "group.RU773P5475.dev.egecam.Doku")
    }
    
    func setAuthState(_ isLoggedIn: Bool) {
        userDefaults?.set(isLoggedIn, forKey: "log_status")
    }
    
    func getAuthState() -> Bool {
        return userDefaults?.bool(forKey: "log_status") ?? false
    }
}


