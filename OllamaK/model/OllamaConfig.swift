//
//  OllamaConfig.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import Foundation


struct OllamaConfig :Codable{
    public static let CONFIG_PATH = "config.json"
    
    /*
     Ollama服务地址
     */
    var url :String
    
    /*
     API Token
     */
    var token: String
    
    /*
     提示词
     */
    var prompt:String
    
    /*
     使用的模型
     */
    var model:String
    
    /*
     模型列表
     */
    var models: [OllamaModel]
    
    /*
     当前的配置
     */
    public static var current: OllamaConfig?
    
    /*
     获取Ollama配置
     */
    public static func getConfig() async -> OllamaConfig?  {
        guard let CONFIG_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(OllamaConfig.CONFIG_PATH) else {
            OllamaConfig.current = nil
            return nil
        }
        do {
            // 从文件读取JSON数据
            let JSON_STRING = try Data(contentsOf: CONFIG_URL)
            
            // 解码JSON数据为OllamaConfig对象
            var config = try JSONDecoder().decode(OllamaConfig.self, from: JSON_STRING)
            config.models = try await getModels(url: config.url)
            print("获取OllamaConfig", config)
            OllamaConfig.current = config
            return config
        } catch {
            OllamaConfig.current = nil
            return nil
        }
    }
    
    public static func getModels(url: String) async throws -> [OllamaModel] {
        let ollamaUrl = "\(url)/api/tags"
        guard let url = URL(string: ollamaUrl) else {
            throw URLError(.badURL)
        }
        print(ollamaUrl)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            // 解析数据
            let modelResponse = try JSONDecoder().decode(OllamaModelResponse.self, from: data)
            print("Fetched models: \(modelResponse.models)")
            return modelResponse.models
        } catch {
            print("Error parsing JSON: \(error)")
            throw error
        }
    }
}
