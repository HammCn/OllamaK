//
//  OllamaRequest.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import Foundation

struct OllamaRequest: Codable {
    var model = ""
    var messages: [OllamaMessage] = []
}
