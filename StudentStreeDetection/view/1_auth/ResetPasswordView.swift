//
//  ResetPasswordView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/30/24.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var email: String = ""
    @StateObject private var vm = AuthenticationManager()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                
                Text("Please enter your email to reset your password. You will receive an email with a link to reset your password.")
                CustomTextField(text: $email, placeholder: "Enter your email")
                    .padding(.vertical)
                
                CustomButton(title: "Reset Password") {
                    Task {
                        await vm.resetPassword(email: email)
                    }
                }
                .alert("Warning", isPresented: $vm.showingPageAlert) {
                    Button("OK", role: .cancel, action: {})
                } message: {
                    Text(vm.pageAlertMessage)
                }
            }
            .padding()
            .padding(.horizontal)
            .navigationTitle("Reset Password")
        }
    }
    
    
}

#Preview {
    NavigationStack {
        ResetPasswordView()
    }
}
