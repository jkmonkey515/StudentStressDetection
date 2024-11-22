//
//  Utils.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import Foundation
import SwiftUI

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

final class Utils {
    static let shared = Utils()
    init() {}
    
    // MARK: - Daily Local Notification as a reminder
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
            } else if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            } else {
                print("Permission denied")
            }
        }
    }
    
    func scheduleDailyNotification(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "This is your daily reminder!"
        content.sound = .default

        // Configure the time trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the request
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Daily notification scheduled at \(hour):\(minute).")
            }
        }
    }
}
