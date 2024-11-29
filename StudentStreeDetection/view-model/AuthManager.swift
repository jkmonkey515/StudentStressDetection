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

@MainActor
final class AuthenticationManager: ObservableObject {
    
    @Published var isLoading = false
    @Published var showingPageAlert = false
    @Published var pageAlertMessage = ""
    @Published var googleAuthSuccess = false
    @Published var facebookAuthSuccess = false
    
    // MARK: Register/Login using email with Firebase
    func createUser(email: String, password: String, name: String) async -> Bool {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = result.user
            let authUser = AppUser(uid: user.uid, name: name, email: user.email)
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
    
}
