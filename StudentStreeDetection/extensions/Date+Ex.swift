//
//  Date+Ex.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/22/24.
//

import Foundation

extension Date {
    /// Converts a `Date` to a `String` with the specified format.
    /// - Parameter format: The desired date format (e.g., "yyyy-MM-dd HH:mm:ss").
    /// - Returns: A formatted date `String`.
    func toString(format: String = "MM/dd/yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension Date {
    static func getCalculatedDate(value: Int, _ date: Date = Date.now) -> Date {
        return Calendar.current.date(byAdding: .day, value: value, to: date)!
    }
    static func getCalculatedMonth(value: Int, _ date: Date = Date.now) -> Date {
        return Calendar.current.date(byAdding: .month, value: value, to: date)!
    }
    static func getCalculatedYear(value: Int, _ date: Date = Date.now) -> Date {
        return Calendar.current.date(byAdding: .year, value: value, to: date)!
    }
    
    
    func subtracting(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: -seconds, to: self)!
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    var month: Int {
        return Calendar(identifier: .iso8601).component(.month,  from: self)
    }
    
    var startOfDay: Date {
        return Calendar(identifier: .iso8601).startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfWeek: Date {
        let calendar = Calendar(identifier: .iso8601)
        return calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        let calendar = Calendar(identifier: .iso8601)
        return calendar.date(byAdding: components, to: startOfWeek)!
    }
    
    func startOfMonth() -> Date {
        return Calendar(identifier: .iso8601).date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar(identifier: .iso8601).date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func createDateInterval(for range: StatsDateType) -> DateInterval? {
        let calendar = Calendar.current
        var startDate: Date?
        var endDate: Date?

        switch range {
        case .weekly:
            startDate = calendar.dateInterval(of: .weekOfYear, for: self)?.start
            endDate = calendar.dateInterval(of: .weekOfYear, for: self)?.end
            
        case .monthly:
            startDate = calendar.dateInterval(of: .month, for: self)?.start
            endDate = calendar.dateInterval(of: .month, for: self)?.end
            
        case .yearly:
            startDate = calendar.dateInterval(of: .year, for: self)?.start
            endDate = calendar.dateInterval(of: .year, for: self)?.end
        }

        if let start = startDate, let end = endDate {
            return DateInterval(start: start, end: end.addingTimeInterval(-1)) // End date inclusive
        }

        return nil
    }
    
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
}

