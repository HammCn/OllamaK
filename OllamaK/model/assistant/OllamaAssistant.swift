//
//  OllamaAssistant.swift
//  OllamaK
//
//  Created by Hamm on 2025/2/10.
//

import Foundation

struct OllamaAssistant: Codable, Identifiable {
    /*
     ID
     */
    let id = UUID()
    
    /*
     名称
     */
    var name: String
    
    /*
     提示词
     */
    var prompt: String
    
    
    init(name: String, prompt: String) {
        self.name = name
        self.prompt = prompt
    }
}
