//
//  OllamaConfig.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import Foundation


struct OllamaConfig :Codable{
    /*
     Ollama服务地址
     */
    var url :String
    
    /*
     API Token
     */
    var token: String
    
    /*
     默认使用的模型
     */
    var defaultModel:String
}
