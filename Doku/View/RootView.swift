//
//  RootView.swift
//  Doku
//
//  Created by Ege Çam on 21.07.2024.
//

import SwiftUI
import AuthenticationServices
import Firebase
import CryptoKit

struct RootView: View {
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.alabaster.ignoresSafeArea() : Color.jet
                .ignoresSafeArea()
            
            if isOnboarding {
              OnboardingView()
            } else {
                Group {
                    if AuthManager.shared.getAuthState() {
                        HomeView()
                    } else {
                        VStack {
                            Text("Doku")
                                .font(.vollkorn(size: 42, weight: 800))
                            
                            Text("Your digital commonplace book")
                                .font(.raleway(size: 20, weight: 500))
                            
                            SignInWithAppleButton { request in
                                let nonce = randomNonceString()
                                self.nonce = nonce
                                request.requestedScopes = [.email, .fullName]
                                request.nonce = sha256(nonce)
                            } onCompletion: { result in
                                switch result {
                                case .success(let authorization):
                                    loginWithFirebase(authorization)
                                    
                                case .failure(let error):
                                    showError(error.localizedDescription)
                                }
                            }
                            .frame(width: 250, height: 45)
                            .clipShape(Capsule())
                            .padding(.top, 50)
                        }
                        .foregroundStyle(colorScheme == .light ? Color.jet : Color.alabaster)
                    }
                }
                .overlay {
                    if isLoading {
                        LoadingScreen()
                    }
                }
                .onAppear {
                    if !AuthManager.shared.getAuthState() {
                        AuthManager.shared.setAuthState(false)
                    }
                }
            }
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    // MARK: Firebase Manager
    
    func loginWithFirebase(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            isLoading = true
            
            guard let nonce else {
                // fatalError("Invalid state: A login callback was received, but no login request was sent.")
                showError("Cannot process your request.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    showError(error.localizedDescription)
                    print(error.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                AuthManager.shared.setAuthState(true)
                isLoading = false
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

#Preview {
    RootView()
}
