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
    
    
    
    func loadMockData() -> [DailyFeelingModel] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return [
            DailyFeelingModel(docId: "15", uid: "user1", level: 4, note: "Great start to the year!", createdAt: formatter.date(from: "2023-1-1")!),
            DailyFeelingModel(docId: "16", uid: "user1", level: 3, note: "Feeling okay", createdAt: formatter.date(from: "2023-1-2")!),
            DailyFeelingModel(docId: "17", uid: "user1", level: 2, note: "Tired but managing", createdAt: formatter.date(from: "2023-1-3")!),
            DailyFeelingModel(docId: "18", uid: "user1", level: 1, note: "Challenging day", createdAt: formatter.date(from: "2023-1-4")!),
            DailyFeelingModel(docId: "19", uid: "user1", level: 3, note: "Average day", createdAt: formatter.date(from: "2023-2-10")!),
            DailyFeelingModel(docId: "20", uid: "user1", level: 4, note: "Good energy", createdAt: formatter.date(from: "2023-3-15")!),
            DailyFeelingModel(docId: "21", uid: "user1", level: 5, note: "Best day ever!", createdAt: formatter.date(from: "2023-4-5")!),
            DailyFeelingModel(docId: "22", uid: "user1", level: 2, note: "Feeling down", createdAt: formatter.date(from: "2023-5-20")!),
            DailyFeelingModel(docId: "23", uid: "user1", level: 1, note: "Not my day", createdAt: formatter.date(from: "2023-6-14")!),
            DailyFeelingModel(docId: "24", uid: "user1", level: 4, note: "Doing well", createdAt: formatter.date(from: "2023-7-30")!),
            DailyFeelingModel(docId: "25", uid: "user1", level: 3, note: "Neutral", createdAt: formatter.date(from: "2023-8-8")!),
            DailyFeelingModel(docId: "26", uid: "user1", level: 5, note: "Feeling great!", createdAt: formatter.date(from: "2023-9-22")!),
            DailyFeelingModel(docId: "27", uid: "user1", level: 2, note: "Struggling a bit", createdAt: formatter.date(from: "2023-10-13")!),
            DailyFeelingModel(docId: "28", uid: "user1", level: 4, note: "Nice day", createdAt: formatter.date(from: "2023-11-4")!),
            DailyFeelingModel(docId: "29", uid: "user1", level: 3, note: "A fine day", createdAt: formatter.date(from: "2023-12-10")!),
            DailyFeelingModel(docId: "30", uid: "user1", level: 5, note: "Amazing energy!", createdAt: formatter.date(from: "2023-12-25")!),
            
            DailyFeelingModel(docId: "1", uid: "user1", level: 3, note: "Feeling okay", createdAt: formatter.date(from: "2024-1-17")!),
            DailyFeelingModel(docId: "2", uid: "user1", level: 4, note: "Good day!", createdAt: formatter.date(from: "2024-1-18")!),
            DailyFeelingModel(docId: "3", uid: "user1", level: 2, note: "Feeling tired", createdAt: formatter.date(from: "2024-1-19")!),
            DailyFeelingModel(docId: "4", uid: "user1", level: 5, note: "Excellent mood!", createdAt: formatter.date(from: "2024-1-20")!),
            DailyFeelingModel(docId: "5", uid: "user1", level: 1, note: "Rough day", createdAt: formatter.date(from: "2024-1-21")!),
            DailyFeelingModel(docId: "6", uid: "user1", level: 3, note: "Feeling neutral", createdAt: formatter.date(from: "2024-1-22")!),
            DailyFeelingModel(docId: "7", uid: "user1", level: 4, note: "Pretty good", createdAt: formatter.date(from: "2024-1-23")!),
            DailyFeelingModel(docId: "8", uid: "user1", level: 2, note: "A bit stressed", createdAt: formatter.date(from: "2024-8-24")!),
            DailyFeelingModel(docId: "9", uid: "user1", level: 5, note: "Feeling awesome!", createdAt: formatter.date(from: "2024-9-25")!),
            DailyFeelingModel(docId: "10", uid: "user1", level: 3, note: "A calm day", createdAt: formatter.date(from: "2024-7-26")!),
            DailyFeelingModel(docId: "11", uid: "user1", level: 1, note: "Overwhelmed", createdAt: formatter.date(from: "2024-10-27")!),
            DailyFeelingModel(docId: "12", uid: "user1", level: 4, note: "Doing well", createdAt: formatter.date(from: "2024-11-28")!),
            DailyFeelingModel(docId: "13", uid: "user1", level: 3, note: "A decent day", createdAt: formatter.date(from: "2024-11-29")!),
            DailyFeelingModel(docId: "14", uid: "user1", level: 2, note: "Low energy", createdAt: formatter.date(from: "2024-11-30")!)
        ]
    }
    
}
