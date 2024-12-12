//
//  OpenAIManager.swift
//  StudentStreeDetection
//
//  Created by Developer on 12/3/24.
//

import Foundation
import OpenAI

final class OpenAIManager {
    static let shared = OpenAIManager()
    init() {}
    
    let openAI = OpenAI(apiToken: OPENAI_API_KEY)
    
    func sendRequest(leve: Int, note: String) async -> Int? {
//      "Classify the stress level (low, medium, high) of the following user comment:\n'\(note)'"
        let query = ChatQuery(messages: [.init(role: .user, content: "Classify the stress level from 1 to 5 of the following user comment:\n'\(note)'")!], model: .gpt3_5Turbo)
        do {
            let result = try await openAI.chats(query: query)
//            print("what is the AI result: ", result.choices.first?.message.content)
            guard let content = result.choices.first?.message.content?.string else {
                return nil
            }
            if let item = Int(content) {
                return item
            } else {
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
