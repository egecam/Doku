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
    @Environment(\.colorScheme) var colorScheme
    @State private var isUserLoggedOut: Bool = false
    @State private var isLoading: Bool = false
    @State private var isAutomaticDownloadsEnabled = false
    @State private var currentAppIcon: String = "AppIcon"
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 1)
    
    private let logger = Logger(subsystem: "dev.egecam.Doku", category: "SettingsView")
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.alabaster.ignoresSafeArea() : Color.jet
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    Text("Settings")
                        .font(.vollkorn(size: 32, weight: 600))
                        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
                        .padding()
                    
                    Spacer()
                }
                
                VStack(spacing: 40) {
                    
                    VStack {
                        Text("Change App Icon")
                            .font(.raleway(size: 18, weight: 500))
                        
                        HStack(spacing: 20) {
                            AppIconButton(iconName: "AppIcon", displayName: "Default", currentIcon: $currentAppIcon)
                            AppIconButton(iconName: "darkDoku", displayName: "Dark Doku", currentIcon: $currentAppIcon)
                            AppIconButton(iconName: "watermelon", displayName: "Watermelon", currentIcon: $currentAppIcon)
                        }
                    }
                    
                    VStack(spacing: 20) {
                        Toggle("Automatic Downloads", systemImage: "arrow.down.circle.dotted", isOn: $isAutomaticDownloadsEnabled)
                            .frame(width: 300)
                            .tint(.coral)
                        
                        Button {
                            
                        } label: {
                            Label("Download for offline use", systemImage: "square.and.arrow.down.fill")
                        }
                        .modifier(SettingsOption())
                        
                        Button {
                            
                        } label: {
                            Label("Delete downloaded data", systemImage: "trash.fill")
                        }
                        .modifier(SettingsOption())
                    }
                    
                    VStack(spacing: 20) {
                        Button {
                            
                        } label: {
                            Label("Recommend a feature", systemImage: "checkmark.bubble.fill")
                        }
                        .modifier(SettingsOption())
                        
                        Button {
                            
                        } label: {
                            Label("Rate Doku on App Store", systemImage: "star.bubble.fill")
                        }
                        .modifier(SettingsOption())
                    }
                    
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
                    .foregroundStyle(.coral)
                    
                    Spacer()
                    
                }
                .padding(.top, 75)
                .font(.raleway(size: 18, weight: 500))
                .overlay {
                    if isLoading {
                        LoadingScreen()
                    }
                }
            }
        }
        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
        .onAppear {
            currentAppIcon = UIApplication.shared.alternateIconName ?? "AppIcon"
        }
    }
}

struct SettingsOption: ViewModifier {
    func body(content: Content) -> some View {
        @Environment(\.colorScheme) var colorScheme
        content
            .background(RoundedRectangle(cornerRadius: 12.0)
                .frame(width: 300, height: 40)
                .foregroundStyle(colorScheme == .light ? .gray.opacity(0.2) : .davysGray))
    }
}

struct AppIconButton: View {
    let iconName: String
    let displayName: String
    @Binding var currentIcon: String
    
    var body: some View {
        Button(action: {
            changeAppIcon(to: iconName)
        }) {
            VStack {
                Image(uiImage: UIImage(imageLiteralResourceName: iconName == "AppIcon" ? "AppIcon" : "\(iconName)"))
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currentIcon == iconName ? Color.davysGray.opacity(0.8) : Color.clear, lineWidth: 3)
                    )
                Text(displayName)
                    .font(.caption)
            }
        }
    }
    
    private func changeAppIcon(to iconName: String) {
        guard UIApplication.shared.alternateIconName != iconName else { return }
        
        UIApplication.shared.setAlternateIconName(iconName == "AppIcon" ? nil : iconName) { error in
            if let error = error {
                print("Error changing app icon: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.currentIcon = iconName
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
