//
//  OpenAIClient.swift
//  StudentStreeDetection
//
//  Created by Developer on 12/3/24.
//

import Foundation
import OpenAI

final class OpenAIClient {
    static let shared = OpenAIClient()
    init() {}
    
    let openAI = OpenAI(apiToken: OPENAI_API_KEY)
    
//    let configuration = OpenAI.Configuration(token: OPENAI_API_KEY, organizationIdentifier: OPENAI_ORGANIZATION_ID, timeoutInterval: 60.0)
//    let openAI = OpenAI(configuration: configuration)
    func sendRequest(leve: Int, note: String) async {
        let query = CompletionsQuery(model: .textDavinci_003, prompt: note, temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
        do {
            let result = try await openAI.completions(query: query)
            print("what is the open ai result for my note:  \n", result)
        } catch {
            print(error.localizedDescription)
            
        }
    }
    
}
