//
//  MainRootView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/20/24.
//

import SwiftUI

struct MainRootView: View {
    
    @State private var text: String = ""
    @State private var currentScore = 0
    
    let emojis: [String] = ["😭", "😢", "😄", "😊", "😍",]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("How are you feeling?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField(text: $text, placeholder: "Enter your feeling")
                    
                    HStack {
                        ForEach(0..<5) { index in
                            Button {
                                currentScore = index + 1
                            } label: {
                                Text("\(emojis[index])")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(currentScore == (index + 1) ? Color.red : Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        }
                    }
                    
                    CustomButton(title: "Submit", isDisabled: isButtonDisabled) {
                        
                    }
                    .padding()
                    .padding(.top, 50)
                }
                .padding()
            }
        }
    }
    
    
    var isButtonDisabled: Bool {
        return currentScore == 0 && text.isEmpty
    }
    
}

#Preview {
    MainRootView()
}
