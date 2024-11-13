//
//  OllamaChatResponse.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import Foundation

/*
 Ollama聊天响应对象
 */
struct OllamaChatResponse: Codable {
    /*
     消息对象
     */
    var message: OllamaMessage
}

/*
 Ollama消息流
 */
struct OllamaChatStream: Codable {
    /*
     是否已完成
     */
    var done: Bool
    
    /*
     响应的消息对象
     */
    var message: OllamaMessage
}
