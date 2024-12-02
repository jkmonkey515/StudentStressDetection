//
//  DailyFeelingModel.swift
//  StudentStreeDetection
//
//  Created by Developer on 12/1/24.
//

import Foundation

struct DailyFeelingModel: Codable {
    var docId: String
    var uid: String
    var level: Int
    var note: String
    var createdAt: Date
    
    var id: String {
        docId
    }

    // For easier initialization
    init(docId: String, uid: String, level: Int, note: String, createdAt: Date = Date()) {
        self.docId = docId
        self.uid = uid
        self.level = level
        self.note = note
        self.createdAt = createdAt
    }
}

struct StatsModel: Codable {
    var id = UUID()
    var startDate: Date // start day of weekly, monthly, yearly statistics data
    var endDate: Date
    var listData: [DailyFeelingModel]
}
