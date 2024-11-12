//
//  MessageAssistantView.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import SwiftUI

struct MessageAssistantView: View {
    @State private var message = ""
    var body: some View {
        HStack{
            Text(message)
            Spacer()
        }
    }
}

#Preview {
    MessageAssistantView()
}
