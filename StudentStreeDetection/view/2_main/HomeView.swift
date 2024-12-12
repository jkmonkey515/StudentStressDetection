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
    
    
    @State private var aiResponse: Int = 0
    @State private var showingConfirmation = false
    
    
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
                            await fetchAIResponse()
                        }
                    } label: {
                        CustomButtonView(title: "Submit")
                    }
//                    .alert("Congrats", isPresented: $showingPageAlert) {
//                        Button("OK", role: .cancel, action: {
//                            cleanData()
//                        })
//                    } message: {
//                        Text(pageAlertMessage)
//                    }
                    .disabled(isLoading || note.isEmpty)
                    .alert("Confirm!", isPresented: $showingConfirmation) {
                        Button("Yes") {
                            Task {
                                await doSubmit()
                            }
                        }
                        Button("No") {
                            self.aiResponse = (selectedFeelingStatus?.index ?? 0) + 1
                            Task {
                                await doSubmit()
                            }
                        }
                    } message: {
                        Text("Your stress level is \(aiResponse). Is it correct?")
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
    
    
    var isButtonDisabled: Bool {
        return selectedFeelingStatus == nil || note.isEmpty
    }
    
    // MARK: - submit feeling
    func fetchAIResponse() async {
        hideKeyboard()
        isLoading = true
        if let aiResponse = await OpenAIManager.shared.sendRequest(leve: (selectedFeelingStatus?.index ?? 0) + 1, note: note) {
            self.aiResponse = aiResponse
        }
        showingConfirmation = true
        isLoading = false
    }
    func doSubmit() async {
        hideKeyboard()
        isLoading = true
        FirestoreManager.shared.submitDailyFeelings(level: (selectedFeelingStatus?.index ?? 0) + 1, note: note, levelByAI: aiResponse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
//        showingConfirmation = false
        showingPageAlert = true
        pageAlertMessage = "Great! Your daily feeling status is sucessfully updated."
        
        clearData()
    }
    
    func clearData() {
        selectedFeelingStatus = nil
        note = ""
        aiResponse = 0
    }
    
}

#Preview {
    MainTabContentView().environmentObject(AppGlobalData())
}
