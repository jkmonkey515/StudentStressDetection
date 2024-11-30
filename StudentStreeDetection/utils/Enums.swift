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

enum AuthPage: String, Codable {
    case login
    case signup
}
