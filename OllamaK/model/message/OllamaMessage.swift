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
    var role: String

    /*
     消息内容
     */
    var content: String
    
    /*
     当前消息缓存路径
     */
    private static let CURRENT_MESSAGE_PATH = "message.json"

    /*
     保存消息
     */
    public static func saveMessage(messages: [OllamaMessage]) {
        guard
            let CONFIG_URL = try? FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask,
                appropriateFor: nil, create: false
            ).appendingPathComponent(OllamaMessage.CURRENT_MESSAGE_PATH)
        else {
            print("无法获取文件路径")
            return
        }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(messages)

            try data.write(to: CONFIG_URL, options: .atomic)
        } catch {
            print("保存消息失败: \(error.localizedDescription)")
        }
    }

    /*
     获取消息
     */
    public static func getMessage() -> [OllamaMessage] {
        guard
            let CONFIG_URL = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            ).first?.appendingPathComponent(OllamaMessage.CURRENT_MESSAGE_PATH)
        else {
            return []
        }
        do {
            let data = try Data(contentsOf: CONFIG_URL)
            let messages = try JSONDecoder().decode(
                [OllamaMessage].self, from: data)
            return messages
        } catch {
            return []
        }
    }
    
    init(role: String, content: String) {
        self.role = role
        self.content = content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let role =
            try container.decodeIfPresent(String.self, forKey: .role) ?? ""
        let content =
            try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.init(role: role, content: content)
    }

    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
}
