//
//  SettingsView.swift
//  Doku
//
//  Created by Ege Çam on 12.07.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import os.log

struct SettingsView: View {
    @State private var isUserLoggedOut: Bool = false
    @State private var isLoading: Bool = false
    
    private let logger = Logger(subsystem: "dev.egecam.Doku", category: "SettingsView")
    
    var body: some View {
        List {
            Section {
                Label("Language", systemImage: "character.book.closed.fill")
                Label("Download for offline use", systemImage: "internaldrive.fill")
            } header: {
                Text("General")
            }
            
            Section {
                Button {
                    do {
                        isLoading = true
                        try Auth.auth().signOut()
                        isUserLoggedOut = true
                        AuthManager.shared.setAuthState(false)
                    } catch {
                        logger.log("\(error.localizedDescription)")
                    }
                } label: {
                    Label("Sign Out", systemImage: "door.right.hand.open")
                }
                .fullScreenCover(isPresented: $isUserLoggedOut, content: {
                    RootView()
                })

            } header: {
                Text("Account")
            }
        }
        .overlay {
            if isLoading {
                LoadingScreen()
            }
        }
    }
}

#Preview {
    SettingsView()
}
