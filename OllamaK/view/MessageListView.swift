//
//  MessageListView.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/13.
//

import SwiftUI

struct MessageListView: View {
    /*
     当前消息
     */
    @Binding public var messages: [OllamaMessage]

    var body: some View {
        ForEach($messages.filter({ item in
            return OllamaMessage.ROLE_SYSTEM != item.role.wrappedValue
        }), id: \.id
        ) { $message in
            MessageItem(message: message)
        }.padding(0)
    }

    /*
     单条消息
     */
    private func MessageItem(message: OllamaMessage) -> some View {
        let config = getMessageItemConfig(role: message.role)
        return HStack {
            HStack {
                if message.role != OllamaMessage.ROLE_ASSISTANT {
                    Spacer()
                }
                Text(message.content)
                    .font(
                        .system(
                            size: config.fontSize)
                    )
                    .padding(12)
                    .foregroundColor(.gray)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                config.bgColor
                                    .opacity(0.1))
                    )
                    .padding(.leading, config.paddingLeft)
                    .padding(.trailing, config.paddingRight)
                    .padding(.vertical, config.verticalPadding)
                    .contextMenu {
                        Button {
                            deleteMessage(item: message)
                        } label: {
                            Label("删除这条消息", systemImage: "trash")
                        }
                    }
                if message.role != OllamaMessage.ROLE_USER {
                    Spacer()
                }
            }
        }
    }
    
    /*
     删除指定索引的历史
     */
    private func deleteMessage(item: OllamaMessage) {
        if let index = messages.firstIndex(where: { $0.id == item.id }) {
            messages.remove(at: index)
        }
        OllamaMessage.saveMessage(messages: messages)
    }

    /*
     获取消息配置
     */
    private func getMessageItemConfig(role: String) -> MessageItemConfig {
        if role == OllamaMessage.ROLE_ASSISTANT {
            return MessageItemConfig.init(
                bgColor: .green, color: .white, paddingLeft: 20,
                paddingRight: 50,
                verticalPadding: 10, fontSize: 15)
        }
        if role == OllamaMessage.ROLE_USER {
            return MessageItemConfig(
                bgColor: .orange, color: .white, paddingLeft: 50,
                paddingRight: 20,
                verticalPadding: 10, fontSize: 15)
        }
        return MessageItemConfig.init(
            bgColor: .gray, color: .gray, paddingLeft: 5, paddingRight: 5,
            verticalPadding: 5, fontSize: 12)
    }
}

/*
 消息显示配置
 */
struct MessageItemConfig {
    /*
     背景色
     */
    var bgColor: Color

    /*
     前景色
     */
    var color: Color

    /*
     左侧Padding
     */
    var paddingLeft: CGFloat

    /*
     右侧Padding
     */
    var paddingRight: CGFloat

    /*
     垂直Padding
     */
    var verticalPadding: CGFloat

    /*
     字体大小
     */
    var fontSize: CGFloat
}
