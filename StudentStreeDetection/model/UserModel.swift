//
//  UserModel.swift
//  StudentStreeDetection
//
//  Created by Developer on 11/27/24.
//

import Foundation

struct AppUser: Codable {
    let uid: String
    var name: String?
    var email: String?
    var countYes: Int?
    var countNo: Int?
    
    static let `default`: AppUser = .init(uid: "", name: "User", email: "user@example.com")
}
struct UserModel: Codable {
    let uid: String
    let name: String?
    let email: String?
    let countOfAgreeWithAI: Int?
    let countOfDisagreeWithAI: Int?
}
