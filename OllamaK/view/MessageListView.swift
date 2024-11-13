//
//  MessageListView.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import SwiftUI

struct MessageListView: View {
    @Binding public var messages: [OllamaMessage]
    
    var body: some View {
        ForEach($messages,id: \.id){ $message in
            if(message.role == OllamaMessage.ROLE_ASSISTANT) {
                HStack{
                    HStack{
                        Text(message.content.isEmpty ? "..." : message.content)
                            .font(.system(size: 16))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.1))
                            )
                            .padding(.leading, 20)
                            .padding(.trailing, 50)
                            .padding(.vertical, 10)
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            if(message.role == OllamaMessage.ROLE_USER) {
                HStack{
                    Spacer()
                    Text(message.content)
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .padding(.trailing, 20)
                        .padding(.leading, 50)
                        .padding(.vertical, 10)
                }
            }
            
            if(message.role == OllamaMessage.ROLE_SYSTEM) {
                HStack{
                    Spacer()
                    Text(message.content)
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(.gray)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal, 5)
                        .padding(.vertical, 10)
                    Spacer()
                }
            }
        }.padding(0)
    }
}
