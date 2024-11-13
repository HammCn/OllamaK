//
//  Message.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import Foundation

/*
 消息对象
 */
struct OllamaMessage: Codable, Identifiable {
    /*
     系统
     */
    public static let ROLE_SYSTEM = "system"
    
    /*
     AI
     */
    public static let ROLE_ASSISTANT = "assistant"
    
    /*
     用户
     */
    public static let ROLE_USER = "user"
    
    /*
     消息ID
     */
    let id = UUID()
    
    /*
     消息角色
     */
    var role:String
    
    /*
     消息内容
     */
    var content:String
    
    
    init(role:String,content:String){
        self.role = role
        self.content = content
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let role = try container.decodeIfPresent(String.self, forKey: .role) ?? ""
        let content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.init(role: role, content: content)
    }

    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
}
