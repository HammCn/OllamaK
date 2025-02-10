//
//  StreamRequestUtil.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import Foundation

/*
 流请求
 */
class StreamRequestUtil {
    /*
     发请求
     */
    static func request(apiURL: String,data:Data) async throws -> AsyncThrowingStream<String, Swift.Error> {
        // 替换 apiURL 中的双斜杠
        let apiURL = apiURL.replacingOccurrences(of: "//", with: "/")
        let url = URL(string: apiURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (result, rsp) = try await URLSession.shared.bytes(for: request)
        guard let response = rsp as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard 200...299 ~= response.statusCode else {
            throw URLError(.badServerResponse)
        }
        return AsyncThrowingStream<String, Swift.Error> { stream in
            Task(priority: .userInitiated) {
                do {
                    for try await line in result.lines {
                        guard let responseData = line.data(using: .utf8) else {
                            throw NSError(domain: "ConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to Data"])
                        }
                        let decoder = JSONDecoder()
                        let ollamaChatStream = try decoder.decode(OllamaChatStream.self, from: responseData)
                        stream.yield(ollamaChatStream.message.content)
                        if ollamaChatStream.done {
                            break
                        }
                    }
                    stream.finish()
                } catch {
                    stream.finish(throwing: error)
                }
                stream.onTermination = { @Sendable status in
                }
            }
        }
    }
}
