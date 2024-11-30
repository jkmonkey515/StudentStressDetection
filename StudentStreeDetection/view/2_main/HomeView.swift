//
//  MainRootView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/20/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var globalData: AppGlobalData
    
    @State private var level = 0
    @State private var note: String = ""
    @State private var isLoading = false
    
    
    let emojis: [String] = ["☹️", "😞", "😑", "😄", "😊"] // ["😢", "😔", "😑", "☺️", "😁"]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    HStack {
                        ForEach(0..<5) { index in
                            Button {
                                level = index + 1
                            } label: {
                                Text("\(emojis[index])")
                                    .font(.system(size: 25))
                                    .padding()
                                    .background(level == (index + 1) ? Color.red : Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding(.vertical)
                    
                    Text("How are you feeling?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextEditor(text: $note)
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
                    
                    if isLoading {
                        LoadingView().padding()
                    }
                    
                    Button {
                        isLoading = true
                        FirestoreManager.shared.submitDailyFeelings(level: level, note: note)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.isLoading = false
                        }
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
        return level == 0 || note.isEmpty
    }
    
}

#Preview {
    MainTabContentView().environmentObject(AppGlobalData())
}
