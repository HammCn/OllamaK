//
//  Message.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import Foundation


struct OllamaMessage: Codable, Identifiable {
    public static let ROLE_SYSTEM = "system"
    public static let ROLE_ASSISTANT = "assistant"
    public static let ROLE_USER = "user"
    
    let id = UUID()
    
    var role = ""
    
    var content = ""
}
