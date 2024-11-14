//
//  MessageHistory.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/14.
//

import Foundation

/*
 消息历史
 */
struct MessageHistory: Codable, Identifiable {
    /*
     ID
     */
    let id = UUID()

    /*
     时间
     */
    var time: String

    /*
     消息列表
     */
    var messages: [OllamaMessage]

    /*
     当前消息历史路径
     */
    private static let HISTORY_MESSAGE_PATH = "history.json"
    
    /*
     添加到历史
     */
    public static func addToHistory(messages: [OllamaMessage]) {
        if messages.count < 2 {
            return
        }
        var history = getHistory()
        let item = MessageHistory.init(
            time: DateTimeUtil.format(date: Date()), messages: messages)
        history.insert(item, at: 0)
        saveHistory(history: history)
    }
    
    /*
     保存历史
     */
    public static func saveHistory(history: [MessageHistory]) {
        guard
            let CONFIG_URL = try? FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask,
                appropriateFor: nil, create: false
            ).appendingPathComponent(MessageHistory.HISTORY_MESSAGE_PATH)
        else {
            print("无法获取文件路径")
            return
        }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(history)

            try data.write(to: CONFIG_URL, options: .atomic)
        } catch {
            print("保存历史失败: \(error.localizedDescription)")
        }
    }

    /*
     获取历史
     */
    public static func getHistory() -> [MessageHistory] {
        guard
            let CONFIG_URL = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            ).first?.appendingPathComponent(MessageHistory.HISTORY_MESSAGE_PATH)
        else {
            return []
        }
        do {
            let data = try Data(contentsOf: CONFIG_URL)
            let history = try JSONDecoder().decode(
                [MessageHistory].self, from: data)
            print("history", history)
            return history
        } catch {
            return []
        }
    }

    init(time: String, messages: [OllamaMessage]) {
        self.time = time
        self.messages = messages
    }

    enum CodingKeys: String, CodingKey {
        case time
        case messages
    }
}
