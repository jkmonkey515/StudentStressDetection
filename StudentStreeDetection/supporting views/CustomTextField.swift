//
//  CustomTextField.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/20/24.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    var imageName: String? = nil
    var isSystemImage = false
    var isBorderRectangle: Bool = true
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .textFieldStyle(AppTextFieldStyle())
                .keyboardType(keyboardType)
                .frame(maxHeight: .infinity)
            
            if let name = imageName {
                if isSystemImage {
                    Image(systemName: name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .symbolRenderingMode(.none)
                } else {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .symbolRenderingMode(.none)
                }
            }
        }
        .frame(height: 46)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: isBorderRectangle ? 10 : 25, style: .continuous)
                .stroke(Color.gray.opacity(0.8), lineWidth: 1))
        .padding(.all, 2)
    }
}

struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .font(.system(size: 17))
            .foregroundColor(Color.init(uiColor: .label))
            .tint(Color.init(uiColor: .label))
            .accentColor(Color.init(uiColor: .label))
    }
}


#Preview {
    CustomTextField(text: .constant(""), placeholder: "Placeholder Text")
}

