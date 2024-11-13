//
//  OllamaRequest.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import Foundation

/*
 Ollama聊天请求对象
 */
struct OllamaChatRequest: Codable {
    /*
     模型名称
     */
    var model = ""
    
    /*
     消息列表
     */
    var messages: [OllamaMessage] = []
    
    /*
     流式输出
     */
    var stream = true
}
