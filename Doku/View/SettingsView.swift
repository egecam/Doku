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
    @State private var selectedIcon: AppIcon = .default
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 1)
    
    
    private let logger = Logger(subsystem: "dev.egecam.Doku", category: "SettingsView")
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.alabaster.ignoresSafeArea() : Color.jet
                .ignoresSafeArea()
            
            VStack {
                HStack(alignment: .bottom) {
                    Text("Settings")
                        .font(.vollkorn(size: 32, weight: 600))
                        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
                        .padding()
                    
                    Spacer()
                }
                
                VStack(spacing: 40) {
                    VStack(spacing: 20) {
                        Toggle("Automatic Downloads", systemImage: "arrow.down.circle.dotted", isOn: $isAutomaticDownloadsEnabled)
                            .padding()
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
                    
                    VStack(spacing: 20) {
                        Text("Customise App Icon")
                        ForEach(AppIcon.allCases, id: \.self) { icon in
                            Toggle(isOn: Binding(
                                get: { selectedIcon == icon },
                                set: { newValue in
                                    if newValue {
                                        selectedIcon = icon
                                        updateIcon()
                                    }
                                }
                            ), label: {
                                HStack {
                                    icon.icon
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    Text(icon.description)
                                        .font(.title3)
                                }
                            })
                            .tint(.coral)
                        }
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
                    .padding(.top, 50)
                    .foregroundStyle(.coral)
                    
                    Spacer()
                    
                }
                .padding(.top, 100)
                .font(.raleway(size: 18, weight: 500))
                .padding()
                .overlay {
                    if isLoading {
                        LoadingScreen()
                    }
                }
            }
        }
        .onAppear {
            getCurrentIcon()
        }
        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
    }
}

struct SettingsOption: ViewModifier {
    func body(content: Content) -> some View {
        @Environment(\.colorScheme) var colorScheme
        content
            .background(RoundedRectangle(cornerRadius: 12.0).frame(width: 300, height: 40).foregroundStyle(colorScheme == .light ? .gray.opacity(0.2) : .davysGray))
    }
}

private extension SettingsView {
    func getCurrentIcon() {
        if let iconName = UIApplication.shared.alternateIconName {
            selectedIcon = AppIcon(from: iconName)
        } else {
            selectedIcon = .default
        }
    }
    
    func updateIcon() {
        Task {
            await CommonUtils.updateAppIcon(with: selectedIcon.name)
        }
    }
}

class CommonUtils {
    static func updateAppIcon(with iconName: String?) async {
        Task {
            do {
                guard await UIApplication.shared.alternateIconName != iconName else {
                    return
                }
                DispatchQueue.main.async {
                    UIApplication.shared.setAlternateIconName(iconName)
                }
            }
            catch {
                print("Could not update icon \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    SettingsView()
}
