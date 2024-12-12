//
//  MainRootView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/20/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var globalData: AppGlobalData

    @State private var selectedFeelingStatus: FeelingStatus? = nil
    @State private var note: String = ""
    @State private var isLoading = false
    @State private var showingPageAlert = false
    @State private var pageAlertMessage = ""
    
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack {
                        ForEach(FeelingStatus.allCases, id: \.self) { item in
                            Button {
                                withAnimation {
                                    selectedFeelingStatus = item
                                }
                            } label: {
                                Image(item.image)
                                    .resizable()
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.all, selectedFeelingStatus == item ? 0 : 10)
                            }
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
                        .submitLabel(.done)
                        .onSubmit {
                            Task {
                                await doSubmit()
                            }
                        }
                    
                    if isLoading {
                        LoadingView().padding()
                    }
                    
                    Button {
                        Task {
                            await doSubmit()
                        }
                    } label: {
                        CustomButtonView(title: "Submit")
                    }
                    .alert("Then you", isPresented: $showingPageAlert) {
                        Button("OK", role: .cancel, action: {
                            cleanData()
                        })
                    } message: {
                        Text(pageAlertMessage)
                    }
                    .disabled(isLoading || note.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
    
    
    var isButtonDisabled: Bool {
        return selectedFeelingStatus == nil || note.isEmpty
    }
    
    // MARK: - submit feedling
    func doSubmit() async {
        hideKeyboard()
        isLoading = true
        let aiResult = await OpenAIManager.shared.sendRequest(leve: (selectedFeelingStatus?.index ?? 0) + 1, note: note)
        FirestoreManager.shared.submitDailyFeelings(level: (selectedFeelingStatus?.index ?? 0) + 1, note: note, levelByAI: aiResult)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
        showingPageAlert = true
        pageAlertMessage = "Great! Your daily feeling status is sucessfully updated."
    }
    
    func cleanData() {
        selectedFeelingStatus = nil
        note = ""
    }
    
}

#Preview {
    MainTabContentView().environmentObject(AppGlobalData())
}
