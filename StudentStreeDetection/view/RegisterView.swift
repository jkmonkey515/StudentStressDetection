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

struct RegisterView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    @State private var email: String = ""
    @State private var password: String = ""
    
    
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
            
            Button {
                globalData.isAuthCompleted = true
            } label: {
                CustomButtonView(title: "Register")
            }
            
            Spacer()
            
            GoogleSignInButton {
                // action
            }
            
            SignInWithAppleButton(
                .signIn, // Button type
                onRequest: { request in
                    // Configure the request
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization): break
                        //handleAuthorization(authorization)
                    case .failure(let error):
                        print("Sign in with Apple failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 46)
            .padding(.bottom, 30)
        }
        .padding()
    }
}

#Preview {
    RegisterView().environmentObject(AppGlobalData())
}
