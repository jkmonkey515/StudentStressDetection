//
//  MainRootView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/20/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    @State private var text: String = ""
    @State private var currentScore = 0
    
    let emojis: [String] = ["☹️", "😞", "😑", "😄", "😊"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    Button {
                        globalData.isAuthCompleted = false
                    } label: {
                        Text("log out")
                    }
                    HStack {
                        ForEach(0..<5) { index in
                            Button {
                                currentScore = index + 1
                            } label: {
                                Text("\(emojis[index])")
                                    .font(.system(size: 25))
                                    .padding()
                                    .background(currentScore == (index + 1) ? Color.red : Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding(.vertical)
                    
                    Text("How are you feeling?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextEditor(text: $text)
                        .frame(height: 150)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.gray.opacity(0.8), lineWidth: 1)
                        )
                        .padding(.bottom)
                    
                    Button {
                        
                    } label: {
                        CustomButtonView(title: "Submit")
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
    
    
    var isButtonDisabled: Bool {
        return currentScore == 0 || text.isEmpty
    }
    
}

#Preview {
    MainTabContentView().environmentObject(AppGlobalData())
}
