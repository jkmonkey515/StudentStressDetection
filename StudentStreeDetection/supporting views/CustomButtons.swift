//
//  CustomButtons.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/21/24.
//

import SwiftUI

// MARK: Button View
struct CustomButtonView: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.system(size: 19, weight: .medium))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.lightPurple, Color.lightOrange]),
                startPoint: .leading,
                endPoint: .trailing))
            .cornerRadius(12)
    }
}

// MARK: Primary Button with action
struct CustomButton: View {
    var title: String = "OK"
    var isDisabled: Bool = false
    var action: () -> Void = {}
    
    var body: some View {
        if isDisabled {
            Button {
                action()
            } label: {
                Text(title)
            }
            .buttonStyle(.disabled)
            .disabled(isDisabled)
        } else {
            Button {
                action()
            } label: {
                Text(title)
            }
            .buttonStyle(.primary)
        }
    }
}

// MARK: - Button Style
extension PrimitiveButtonStyle where Self == AppButtonStyle {
    static var primary: Self { Self() }
}
extension PrimitiveButtonStyle where Self == AppDisabledButtonStyle {
    static var disabled: Self { Self() }
}

// MARK: Primary Button Style
struct AppButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        Button {
            configuration.trigger()
        } label: {
            configuration.label
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(Color.white)
                .tint(Color.blue)
                .frame(height: ButtonHeight)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.lightPurple, Color.lightOrange]),
                    startPoint: .leading,
                    endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: ButtonCornerRadius))
                
        }
        .controlSize(.large)
    }
}
// MARK: Disabled button style
struct AppDisabledButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        Button {
            configuration.trigger()
        } label: {
            configuration.label
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.5))
                .tint(Color.gray.opacity(0.8))
                .frame(height: ButtonHeight)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.lightPurple, Color.lightOrange]),
                    startPoint: .leading,
                    endPoint: .trailing))
                .opacity(0.6)
                .clipShape(RoundedRectangle(cornerRadius: ButtonCornerRadius))
        }
        .controlSize(.large)
    }
}


// MARK: Preview
#Preview {
    VStack {
        CustomButton(title: "Next", isDisabled: false) {
            // action
        }
        CustomButton(title: "Next", isDisabled: true) {
            // action
        }
        
        CustomButtonView(title: "Button View")
    }
    .padding()
}
