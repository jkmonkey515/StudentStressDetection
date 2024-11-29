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
            mainView
        }
    }
    
    var mainView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Button{
                globalData.isAuthCompleted = true
            } label: {
                Text("login")
            }
            CustomTextField(text: $email, placeholder: "Email address")
            
            PasswordField(password: $password)
            
            if vm.isLoading {
                LoadingView()
                    .padding()
            }
            
            Button {
                doRegister()
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
            
            
            HStack(spacing: 30) {
                Button {
                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                    let request = appleIDProvider.createRequest()
                    request.requestedScopes = [.fullName, .email]
                    currentNonce = Utils.shared.randomNonceString()
                    request.nonce = Utils.shared.sha256(currentNonce)
                    
                    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                    authorizationController.delegate = AppleSignInDelegate()
                    authorizationController.presentationContextProvider = AppleSignInDelegate()
                    authorizationController.performRequests()
                }label: {
                    Image("ic_apple.login")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 50, height: 50)
                }
                
                Button {
                    vm.googleSignin()
                }label: {
                    Image("ic_google.login")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 50, height: 50)
                }
                .onChange(of: vm.googleAuthSuccess) { _, _ in
                    globalData.isAuthCompleted = vm.googleAuthSuccess
                }
                .disabled(vm.isLoading)
            }
            .padding(.bottom)
        }
        .padding()
        .padding(.horizontal)
    }
    
    // MARK: - validation of email and password
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty && !vm.isLoading
    }
    
    // MARK: - handle email register
    func doRegister() {
        hideKeyboard()
        Task {
            let success = await vm.createUser(email: email, password: password, name: "")
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

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            
            print("User ID: \(userID)")
            print("Email: \(email ?? "No Email")")
            print("Full Name: \(fullName?.givenName ?? "No Name")")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed: \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
}
