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
            let data = try Data(contentsOf: CONFIG_URL)
            var config = try JSONDecoder().decode(OllamaConfig.self, from: data)
            config.models = try await getModels(url: config.url)
            print("获取OllamaConfig", config)
            OllamaConfig.current = config
            return config
        } catch {
            OllamaConfig.current = nil
            return nil
        }
    }
    
    /*
     获取模型列表
     */
    public static func getModels(url: String) async throws -> [OllamaModel] {
        var ollamaUrl = "\(url)/api/tags"
        ollamaUrl = ollamaUrl.replacingOccurrences(of: "//", with: "/")
        guard let requestUrl = URL(string: ollamaUrl) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let modelResponse = try JSONDecoder().decode(OllamaModelResponse.self, from: data)
        return modelResponse.models
    }
}
