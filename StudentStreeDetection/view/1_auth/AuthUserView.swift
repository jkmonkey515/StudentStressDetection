//
//  AuthUserView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/30/24.
//

import SwiftUI

struct AuthUserView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    @State private var email: String = ""
    @State private var password: String = ""
    @StateObject private var vm = AuthenticationManager()
    @State private var currentPage: AuthPage = .login
    
    var body: some View {
        NavigationStack {
            mainView
                .navigationTitle(currentPage == .login ? "Sign in" : "Register")
        }
    }
    
    var mainView: some View {
        VStack(spacing: 30) {
            Spacer()
            CustomTextField(text: $email, placeholder: "Email address")
            
            PasswordField(password: $password)
            
            if currentPage == .login {
                NavigationLink {
                    ResetPasswordView()
                } label: {
                    Text("Forgot password?")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
            
            
            Button {
                if currentPage == .signup {
                    doRegister()
                } else {
                    doLogin()
                }
            } label: {
                if vm.isLoading {
                    HStack {
                        LoadingView(color: .white)
                        
                        Text(currentPage == .signup ? "Signing up..." : "Logging in...")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color.lightPurple, Color.lightOrange]),
                        startPoint: .leading,
                        endPoint: .trailing))
                    .cornerRadius(12)
                } else {
                    CustomButtonView(title: currentPage == .signup ? "Register" : "Sign in")
                }
            }
            .disabled(!isValid)
            .alert("Warning", isPresented: $vm.showingPageAlert) {
                Button("OK", role: .cancel, action: {})
            } message: {
                Text(vm.pageAlertMessage)
            }
            
            HStack {
                Text("By signing \(currentPage == .signup ? "up" : "in")")
                Text("you accept our")
                Text("Terms of agreement.")
                    .foregroundColor(.blue)
                    .underline()
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://apple.com")!)
                    }
            }
            .font(.caption)
            
            Spacer()
            
            if currentPage == .login {
                signupView
            } else {
                loginView
            }
            
            
            socialLoginView
        }
        .padding()
        .padding(.horizontal)
    }
    
    var loginView: some View {
        HStack(spacing: 20) {
            Text("Already have an account?")

            Button {
                withAnimation {
                    currentPage = .login
                }
            } label: {
                Text("Sign in")
                    .foregroundStyle(Color.lightPurple)
                    .font(.system(size: 18))
            }
        }
    }
    
    var signupView: some View {
        HStack(spacing: 20) {
            Text("Don't have an account?")

            Button {
                withAnimation {
                    currentPage = .signup
                }
            } label: {
                Text("Sign Up")
                    .foregroundStyle(Color.lightPurple)
                    .font(.system(size: 18))
            }
        }
    }
    
    // MARK: - Social Login view
    var socialLoginView: some View {
        VStack {
            ZStack {
                Divider()
                Text("OR")
                    .padding()
                    .background()
            }
            
            VStack {
                Text("Sign in with Social Networks")
                
                HStack(spacing: 30) {
                    Button {
                        vm.signInWithAppleFlow()
                    }label: {
                        Image("ic_apple.login")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.black)
                    }
                    .onChange(of: vm.appleAuthSuccess) { oldValue, newValue in
                        globalData.isAuthCompleted = vm.appleAuthSuccess
                    }
                    
                    Button {
                        vm.googleSignin()
                    }label: {
                        Image("ic_google.login")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.red.opacity(0.8))
                    }
                    .onChange(of: vm.googleAuthSuccess) { _, _ in
                        globalData.isAuthCompleted = vm.googleAuthSuccess
                    }
                    .disabled(vm.isLoading)
                }
                .padding(.bottom)
            }
        }
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
    
    func doLogin() {
        hideKeyboard()
        Task {
            let success = await vm.login(email: email, password: password)
            withAnimation {
                globalData.isAuthCompleted = success
            }
        }
    }
}

#Preview {
    AuthUserView()
}
