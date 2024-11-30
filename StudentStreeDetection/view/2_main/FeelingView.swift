//
//  FeelingView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/21/24.
//

import SwiftUI

struct FeelingView: View {
    @State private var selectedMood: Int? = nil
    @State private var feelingText: String = ""
    
    var body: some View {
        VStack {
            // Reminder Banner
            Text("Don't forget to check in today!")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.teal]),
                    startPoint: .leading,
                    endPoint: .trailing))
                .cornerRadius(12)
                .padding(.top, 20)
            
            Spacer()
            
            // Smiley Face Scale
            Text("How are you feeling today?")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 20)
            
            HStack(spacing: 15) {
                ForEach(1...5, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        Image(systemName: selectedMood == mood ? "face.smiling.fill" : "face.smiling")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(selectedMood == mood ? .yellow : .gray)
                    }
                }
            }
            
            Spacer().frame(height: 40)
            
            // Free-form Text Box
            VStack(alignment: .leading) {
                Text("Tell us more about your feelings:")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                TextEditor(text: $feelingText)
                    .frame(height: 150)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Submit Button
            Button(action: {
                // Handle submission logic
                print("Mood: \(selectedMood ?? 0), Text: \(feelingText)")
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.green]),
                        startPoint: .leading,
                        endPoint: .trailing))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(LinearGradient(
            gradient: Gradient(colors: [Color(.systemMint), Color(.systemTeal)]),
            startPoint: .top,
            endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    FeelingView()
}
