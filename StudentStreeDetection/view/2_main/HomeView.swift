//
//  MainRootView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/20/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var globalData: AppGlobalData

    @State private var selectedFeelingStatusIndex: Int = -1
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
                                    if selectedFeelingStatusIndex == item.index {
                                        selectedFeelingStatusIndex = -1
                                    } else {
                                        selectedFeelingStatusIndex = item.index
                                    }
                                }
                            } label: {
                                Image(item.image)
                                    .resizable()
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.all, selectedFeelingStatusIndex == item.index ? 0 : 10)
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
                    
                    Text("Tell me more about what is feeling good and what’s feeling hard today")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom)
                    
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
                    .disabled(isLoading || isButtonDisabled)
                    .alert("Confirm!", isPresented: $showingConfirmation) {
                        Button("Yes") {
                            Task {
                                await doSubmit(agreed: true)
                            }
                        }
                        Button("No") {
                            self.aiResponse = selectedFeelingStatusIndex + 1
                            Task {
                                await doSubmit(agreed: false)
                            }
                        }
                    } message: {
                        Text("Your stress level is \(Utils.shared.getStressLevelText(from: Double(aiResponse))). Is it correct?")
                    }
                }
                .padding()
            }
            .navigationTitle("Untangle emotions")
        }
    }
    
    
    var isButtonDisabled: Bool {
        return selectedFeelingStatusIndex == -1 || note.isEmpty
    }
    
    // MARK: - submit feeling
    func fetchAIResponse() async {
        hideKeyboard()
        if isButtonDisabled {
            showingPageAlert = true
            pageAlertMessage = "Please select one of emojis and add your notes."
            return
        }
        isLoading = true
        if let aiResponse = await OpenAIManager.shared.sendRequest(leve: selectedFeelingStatusIndex + 1, note: note) {
            self.aiResponse = aiResponse
            self.showingConfirmation = true
        } else {
            showingPageAlert = true
            pageAlertMessage = "We didn't get the response from AI. Please try again."
        }
        
        isLoading = false
    }
    func doSubmit(agreed: Bool) async {
        hideKeyboard()
        isLoading = true
        FirestoreManager.shared.submitDailyFeelings(level: selectedFeelingStatusIndex + 1, note: note, levelByAI: aiResponse)
        await FirestoreManager.shared.increaseAICount(agreed: agreed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
        showingPageAlert = true
        pageAlertMessage = "Great! Your daily feeling status is sucessfully updated."
        
        clearData()
    }
    
    func clearData() {
        selectedFeelingStatusIndex = -1
        note = ""
        aiResponse = 0
    }
    
}

#Preview {
    MainTabContentView().environmentObject(AppGlobalData())
}
