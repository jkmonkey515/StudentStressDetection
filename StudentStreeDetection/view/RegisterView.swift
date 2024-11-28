//
//  RegisterView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import SwiftUI
import UserNotifications
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    @State private var email: String = ""
    @State private var password: String = ""
    @StateObject private var vm = AuthenticationManager()
    @State private var currentNonce = "" // for apple auth
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightPink.ignoresSafeArea()
                
                mainView
            }
        }
    }
    
    var mainView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            CustomTextField(text: $email, placeholder: "Email address")
            CustomTextField(text: $password, placeholder: "Password")
            
            if vm.isLoading {
                LoadingView()
                    .padding()
            }
            
            Button {
                doLogin()
            } label: {
                CustomButtonView(title: "Register")
            }
            .disabled(!isValid)
            .alert("Warning", isPresented: $vm.showingPageAlert) {
                Button("OK", role: .cancel, action: {})
            } message: {
                Text(vm.pageAlertMessage)
            }
            
            Spacer()
            // MARK: - google signin
            GoogleSignInButton {
                vm.googleSignin()
            }
            .onChange(of: vm.googleAuthSuccess) { _, _ in
                globalData.isAuthCompleted = vm.googleAuthSuccess
            }
            .disabled(vm.isLoading)
            
            // MARK: - apple signiin
            SignInWithAppleButton(
                .signIn, // Button type
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                    currentNonce = Utils.shared.randomNonceString()
                    request.nonce = Utils.shared.sha256(currentNonce)
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleAppleAuthResult(authorization)
                    case .failure(let error):
                        print("Sign in with Apple failed: \(error.localizedDescription)")
                        vm.showingPageAlert = true
                        vm.pageAlertMessage = "Sign in with Apple failed: The operation couldn’t be completed."
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 46)
            .padding(.bottom, 30)
            .disabled(vm.isLoading)
        }
        .padding()
    }
    
    // MARK: - validation of email and password
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty && !vm.isLoading
    }
    
    // MARK: - handle email signin
    func doLogin() {
        hideKeyboard()
        Task {
            let success = await vm.login(email: email, password: password)
            withAnimation {
                globalData.isAuthCompleted = success
            }
        }
    }
    // MARK: - handle Apple signin
    func handleAppleAuthResult(_ authResult: ASAuthorization) {
        hideKeyboard()
        if let credential = authResult.credential as? ASAuthorizationAppleIDCredential {
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
                    
                    withAnimation {
                        globalData.isAuthCompleted = true
                    }
                } catch {
                    vm.showingPageAlert = true
                    vm.pageAlertMessage = "Failed to authenticate your credential. Try again later."
                }
            }
        } else {
            vm.showingPageAlert = true
            vm.pageAlertMessage = "Something went wrong in doing Apple Sign In."
        }
    }
}

#Preview {
    RegisterView().environmentObject(AppGlobalData())
}
