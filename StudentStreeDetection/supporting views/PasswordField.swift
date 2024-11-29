//
//  PasswordField.swift
//  StudentStreeDetection
//
//  Created by Developer on 11/29/24.
//

import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    var placeholder: String = "Enter password"
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        HStack {
            if isPasswordVisible {
                TextField("Enter password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                SecureField("Enter password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 46)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.8), lineWidth: 1)
        )
    }
}

#Preview {
    PasswordField(password: .constant(""))
}
