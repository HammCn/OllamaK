//
//  OllamaModelResponse.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import Foundation


struct OllamaModelResponse: Codable {
    // models 是 OllamaModel 的数组
    var models:[OllamaModel]
}

struct OllamaModel:Identifiable,Codable{
    let id  = UUID()
    /*
     模型名称
     */
    var name:String
}
