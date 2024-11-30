//
//  SettingsView.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var isDailyNotification: Bool = false
    @State private var selectedTime = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                Toggle("Daily Notification", isOn: $isDailyNotification)
                    .padding()
                
                if isDailyNotification {
                    Text("Select a Time")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    DatePicker(
                        "Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    
                    Text("Selected Time: \(formattedTime)")
                        .padding()
                    
                    Button {
                        Utils.shared.scheduleDailyNotification(hour: hourValue, minute: minuteValue)
                    } label: {
                        CustomButtonView(title: "Save")
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
        }
        
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
    
    var hourValue: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: selectedTime)
        if let hour = Int(hourString) {
            return hour
        } else {
            return 9
        }
    }
    var minuteValue: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let hourString = dateFormatter.string(from: selectedTime)
        if let hour = Int(hourString) {
            return hour
        } else {
            return 9
        }
    }
}

#Preview {
    MainTabContentView().environmentObject(AppGlobalData())
}
