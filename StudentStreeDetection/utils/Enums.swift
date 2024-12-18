//
//  Enums.swift
//  StudentStreeDetection
//
//  Created by Bright on 11/30/24.
//

import Foundation

public enum StudentStreeDetectionError: Error {
    case invalidImage
    case invalidImageSize
    case invalidImageFormat
    case invalidImageOrientation
    case invalidImagePixelFormat
    case invalidImageColorSpace
    case invalidImageAlphaInfo
}

enum BarChartMode: String, Codable {
    case user
    case ai
}

enum AuthPage: String, Codable {
    case login
    case signup
}

enum FeelingStatus: String, Codable, CaseIterable {
    case cry
    case frowning
    case neutral
    case relieved
    case grin
    
    var title: String {
        switch self {
        case .cry:
            "Very Sad"
        case .frowning:
            "Sad"
        case .neutral:
            "Neutral"
        case .relieved:
            "Happy"
        case .grin:
            "Very Happy"
        }
    }
    var index: Int {
        FeelingStatus.allCases.firstIndex(of: self) ?? 0
    }

    var image: String {
        switch self {
        case .cry:
            "1_cry"
        case .frowning:
            "2_slightly_frowning_face"
        case .neutral:
            "3_neutral_face"
        case .relieved:
            "4_relieved"
        case .grin:
            "5_grin"
        }
    }
    
}

enum StatsDateType: String, CaseIterable {
    case weekly
    case monthly
    case yearly
    
    var title: String {
        rawValue.capitalized
    }
    var index: Int {
        StatsDateType.allCases.firstIndex(of: self) ?? 0
    }
}
