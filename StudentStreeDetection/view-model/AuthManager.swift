//
//  AuthManager.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/28/24.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import SwiftUI
import AuthenticationServices

@MainActor
final class AuthenticationManager: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @Published var isLoading = false
    @Published var showingPageAlert = false
    @Published var pageAlertMessage = ""
    @Published var googleAuthSuccess = false
    @Published var appleAuthSuccess = false
    
    @Published var currentNonce = ""
    
    //MARK: - Apple sign in with Customized button
    func signInWithAppleFlow() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            var name = ""
            if let fullname = credential.fullName {
                if let givenname = fullname.givenName {
                    name = givenname
                }
                if let familyname = fullname.familyName {
                    name = name + " " + familyname
                }
            } else {
                print("NO name available from Apple.")
            }
            guard let data = credential.identityToken, let tokenString = String(data: data, encoding: .utf8) else { return }
            
            let firebaseCredential = OAuthProvider.credential(providerID: .apple, idToken: tokenString, rawNonce: currentNonce)
            Task {
                do {
                    let result = try await Auth.auth().signIn(with: firebaseCredential)
                    let user = result.user
                    let existingUser = await FirestoreManager.shared.fetchUser(uid: user.uid)
                    if let _ = existingUser {
                        let authUser = AppUser(uid: user.uid, email: user.email)
                        UserData.shared.setUser(authUser)
                    } else {
                        let authUser = AppUser(uid: user.uid, email: user.email)
                        FirestoreManager.shared.createUser(uid: user.uid, name: name, photo: user.photoURL?.absoluteString ?? "")
                        UserData.shared.setUser(authUser)
                    }
                    
                    appleAuthSuccess = true
                } catch {
                    showingPageAlert = true
                    pageAlertMessage = "Failed to authenticate your credential. Try again later."
                }
            }
            
        } else {
            showingPageAlert = true
            pageAlertMessage = "Something went wrong in doing Apple Sign In."
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showingPageAlert = true
        pageAlertMessage = error.localizedDescription
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
    
    // MARK: Register/Login using email and password with Firebase
    func createUser(email: String, password: String, name: String) async -> Bool {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = result.user
            let authUser = AppUser(uid: user.uid, name: name, email: user.email)
            FirestoreManager.shared.createUser(uid: user.uid, name: name, photo: user.photoURL?.absoluteString ?? "")
            UserData.shared.setUser(authUser)
            isLoading = false
            return true
        } catch {
            isLoading = false
            showingPageAlert = true
            pageAlertMessage = error.localizedDescription
            print("Error Creating User: ", error.localizedDescription)
            return false
        }
    }
    
    func login(email: String, password: String) async -> Bool {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            let user = result.user
            let existingUser = await FirestoreManager.shared.fetchUser(uid: user.uid)
            if let _ = existingUser {
                let authUser = AppUser(uid: user.uid, email: user.email)
                UserData.shared.setUser(authUser)
            } else {
                let authUser = AppUser(uid: user.uid, email: user.email)
                UserData.shared.setUser(authUser)
            }
            isLoading = false
            return true
        } catch(let error) {
            print("email auth failed:", error.localizedDescription)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Google Signin with Firebase
    func googleSignin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            googleAuthSuccess = false
            return
        }
        let configuration = GIDConfiguration(clientID: clientID)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        GIDSignIn.sharedInstance.configuration = configuration
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController){[weak self] user, error in
            self?.authenticateUser(for: user?.user, with: error)
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let error {
            googleAuthSuccess = false
            showingPageAlert = true
            pageAlertMessage = error.localizedDescription
        }
        guard let authentication = user, let idToken = authentication.idToken else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: authentication.accessToken.tokenString)
        Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                var name = ""
                if let givenname = authentication.profile?.givenName {
                    name = givenname
                }
                if let familyname = authentication.profile?.familyName {
                    name = name + " " + familyname
                }
                var imageUrl = ""
                if let url = authentication.profile?.imageURL(withDimension: 240) {
                    imageUrl = "\(url)"
                }
                
                let user = result.user
                let existingUser = await FirestoreManager.shared.fetchUser(uid: user.uid)
                if let u = existingUser {
                    let authUser = AppUser(uid: user.uid, name: u.name, email: user.email)
                    UserData.shared.setUser(authUser)
                } else {
                    let newUser = AppUser(uid: user.uid, email: user.email)
                    FirestoreManager.shared.createUser(uid: user.uid, name: name, photo: imageUrl)
                    UserData.shared.setUser(newUser)
                }
                
                googleAuthSuccess = true
            } catch {
                googleAuthSuccess = false
                showingPageAlert = true
                pageAlertMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - reset password: forgot password
    func resetPassword(email: String) async {
        do {
            isLoading = true
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isLoading = false
            showingPageAlert = true
            pageAlertMessage = "Password reset email sent."
        } catch {
            isLoading = false
            showingPageAlert = true
            pageAlertMessage = error.localizedDescription
        }
    }
    
}
