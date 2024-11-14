//
//  ContentView.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct HomeView: View {
    /*
     窗口标题
     */
    @State private var title = "Hi OllamaK!"

    /*
     是否已连接模型服务
     */
    @State private var isConnected = true

    /*
     是否显示设置窗口
     */
    @State private var showSetting = false

    /*
     当前消息列表
     */
    @State private var messages: [OllamaMessage] = []

    /*
     是否正在请求中
     */
    @State private var isRequesting = false

    /*
     输入的内容
     */
    @State private var inputContent = ""

    /*
     滚动代理
     */
    @State private var scrollViewProxy: ScrollViewProxy?

    var body: some View {
        NavigationStack {
            VStack {
                if isConnected {
                    ScrollViewReader { proxy in
                        ScrollView {
                            MessageListView(messages: $messages)
                            Text("").id("message-list")
                        }
                        .padding(0)
                        .onAppear {
                            scrollViewProxy = proxy
                        }
                    }
                    HStack {
                        Menu {
                            Button {
                                messages = []
                                addSystemPromptMessage()
                            } label: {
                                Text("新的篇章")
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(
                                        isRequesting ? .gray : .primary
                                    )
                            }

                            Button {
                                messages = []
                                addSystemPromptMessage()
                            } label: {
                                Text("会话历史")
                                Image(systemName: "clock.badge")
                                    .foregroundStyle(
                                        isRequesting ? .gray : .primary
                                    )
                            }

                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                        .disabled(isRequesting)
                        TextField(
                            isRequesting ? "思考中..." : "说点什么吧...",
                            text: $inputContent
                        )
                        .onSubmit {
                            Task {
                                await send()
                            }
                        }
                        .disabled(isRequesting)
                        .submitLabel(.send)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal, 5)
                        Button(
                            action: {
                                Task {
                                    await send()
                                }
                            },
                            label: {
                                Image(
                                    systemName: isRequesting
                                        ? "ellipsis.circle"
                                        : "chevron.up.circle.fill"
                                )
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(
                                    inputContent.isEmpty || isRequesting
                                        ? .gray : .primary)
                            }
                        )
                        .disabled(inputContent.isEmpty || isRequesting)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .padding(.bottom, 10)
                } else {
                    SettingTipView()
                        .onTapGesture {
                            showSetting = true
                        }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar(
                content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                showSetting = true
                            }) {
                                HStack {
                                    Text("服务配置")
                                    Image(systemName: "wifi.router")
                                }
                            }
                            Button(
                                action: {
                                    let url = URL(
                                        string:
                                            "https://github.com/HammCn/OllamaK"
                                    )!
                                    UIApplication.shared.open(url)
                                }) {
                                    HStack {
                                        Text("关于项目")
                                        Image(systemName: "book.and.wrench")
                                    }
                                }
                        } label: {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .scaleEffect(1)
                        }
                        .disabled(isRequesting)
                    }
                })
                .sheet(
                    isPresented: $showSetting,
                    onDismiss: {
                        reloadConfig()
                    },
                    content: {
                        SettingView()
                    })
        }
        .onAppear {
            reloadConfig()
        }
    }

    /*
     发送
     */
    private func send() async {
        isRequesting = true
        messages.append(
            OllamaMessage.init(
                role: OllamaMessage.ROLE_USER,
                content: inputContent
            )
        )
        inputContent = ""
        messages.append(
            OllamaMessage.init(
                role: OllamaMessage.ROLE_ASSISTANT,
                content: ""
            )
        )
        scrollToBottom()
        let ollamaRequest = OllamaChatRequest(model: title, messages: messages)

        let ollamaUrl = OllamaConfig.current!.url + "/api/chat"

        let jsonData = try? JSONEncoder().encode(ollamaRequest)
        do {
            let stream: AsyncThrowingStream =
                try await StreamRequestUtil.request(
                    apiURL: ollamaUrl,
                    data: jsonData!
                )
            for try await text in stream {
                await MainActor.run {
                    var lastMessage = messages[messages.count - 1]
                    lastMessage.content += text
                    messages[messages.count - 1] = lastMessage
                    scrollToBottom()
                }
            }
        } catch {
            var lastMessage = messages[messages.count - 1]
            lastMessage.content = "请求失败 - \(error.localizedDescription)"
            messages[messages.count - 1] = lastMessage
            scrollToBottom()
        }
        isRequesting = false
    }

    /*
     滚动到底部
     */
    private func scrollToBottom() {
        scrollViewProxy?.scrollTo("message-list", anchor: .bottom)
    }

    /*
     添加Prompt
     */
    private func addSystemPromptMessage() {
        if messages.isEmpty {
            messages.append(
                OllamaMessage.init(
                    role: OllamaMessage.ROLE_SYSTEM,
                    content: OllamaConfig.current!.prompt
                )
            )
        }
    }

    /*
     加载配置
     */
    private func reloadConfig() {
        Task {
            isConnected = false
            let config = await OllamaConfig.getConfig()
            if config == nil {
                showSetting = true
                return
            }
            title = OllamaConfig.current!.model
            isConnected = true
            addSystemPromptMessage()
        }
    }
}
