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
    var levelByAI: Int
    var createdAt: Date
    
    var id: String {
        docId
    }

    // For easier initialization
    init(docId: String, uid: String, level: Int, note: String, levelByAI: Int, createdAt: Date = Date()) {
        self.docId = docId
        self.uid = uid
        self.level = level
        self.note = note
        self.levelByAI = levelByAI
        self.createdAt = createdAt
    }
    
    static let `default` = Self(docId: "", uid: "", level: 5, note: "Feeling great!", levelByAI: 1)
}

struct StatsModel: Codable, Identifiable {
    var id = UUID()
    var startDate: Date // start day of weekly, monthly, yearly statistics data
    var endDate: Date
    var listData: [DailyFeelingModel]
}
