//
//  Utils.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import Foundation
import SwiftUI
import CryptoKit

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

final class Utils {
    static let shared = Utils()
    init() {}
    
    // Helper function to group DailyFeelings by weekly, monthly, and yearly
    func groupDataByInterval(data: [DailyFeelingModel], type: StatsDateType = .weekly) -> [StatsModel] {
        var interval: Calendar.Component = .weekOfYear
        switch type {
        case .weekly:
            interval = .weekOfYear
        case .monthly:
            interval = .month
        case .yearly:
            interval = .year
        }
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: data) { feeling -> Date in
            let startOfInterval = calendar.dateInterval(of: interval, for: feeling.createdAt)?.start
            return startOfInterval ?? feeling.createdAt
        }

        return grouped.map { startDate, feelings in
            let endDate = calendar.date(byAdding: interval, value: 1, to: startDate)?.addingTimeInterval(-1) ?? startDate
            return StatsModel(startDate: startDate, endDate: endDate, listData: feelings)
        }
    }
    
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
    
    // MARK: For Apple Auth with Firebase
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    
    
    
}
