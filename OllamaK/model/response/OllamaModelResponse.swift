//
//  OllamaModelResponse.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import Foundation

/*
 Ollama 列出模型响应对象
 */
struct OllamaModelResponse: Codable {
    /*
     模型列表
     */
    var models:[OllamaModel]
}

/*
 Ollama模型对象
 */
struct OllamaModel:Identifiable,Codable{
    /*
     ID
     */
    let id  = UUID()
    
    /*
     模型名称
     */
    var name:String
    
    
    init(name: String){
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.init(name: name)
    }

    enum CodingKeys: String, CodingKey {
        case name
    }
}
