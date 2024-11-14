//
//  MessageHistoryView.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/14.
//

import SwiftUI

struct MessageHistoryView: View {
    /*
     历史
     */
    @State private var history: [MessageHistory] = []

    /*
     窗口
     */
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                if $history.count > 0 {
                    List {
                        ForEach($history, id: \.id) { $item in
                            HistoryItem(item: item)
                        }
                    }
                } else {
                    EmptyStatusView(message: "历史都被你删光啦~")
                }
            }
            .toolbar {
                TopRightButton()
            }
            .padding(.top, 10)
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("会话历史")
            .navigationBarTitleDisplayMode(.automatic)
            .onAppear {
                getHistory()
            }
        }
        .colorScheme(.dark)
    }

    /*
     消息历史行
     */
    private func HistoryItem(item: MessageHistory) -> some View {
        return VStack(
            alignment: .leading,
            content: {
                Text(
                    item.time
                )
                .font(.system(size: 14))
                .foregroundStyle(.gray)
                .padding(.bottom, 5)
                Text(
                    item.messages[1].content
                )
                .font(.system(size: 16))
            }
        )
        .swipeActions {
            Button(role: .destructive) {
                deleteHistory(item: item)
            } label: {
                Label("删除", systemImage: "trash")
            }
            Button(role: .cancel) {
                OllamaMessage.saveMessage(messages: item.messages)
                presentationMode.wrappedValue.dismiss()
            } label: {
                Label("继续", systemImage: "text.bubble")
            }
        }
    }

    /*
     顶部右上角按钮
     */
    private func TopRightButton() -> some View {
        return Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Text("确定")
        }
    }

    /*
     删除指定索引的历史
     */
    private func deleteHistory(item: MessageHistory) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history.remove(at: index)
        }
        MessageHistory.saveHistory(history: history)
    }

    /*
     获取消息历史
     */
    private func getHistory() {
        history = MessageHistory.getHistory()
    }
}
