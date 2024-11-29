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
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    PasswordField(password: .constant(""))
}
