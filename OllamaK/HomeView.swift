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
     是否显示历史消息窗口
     */
    @State private var showMessageHistory = false

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
     底部按钮大小
     */
    private let footerButtonSize: CGFloat = 28

    /*
     输入框焦点
     */
    @FocusState private var focusedField: Field?

    /*
     最后消息的标记
     */
    private let lastMessageTag = "message-list"

    /*
     输入焦点枚举
     */
    private enum Field {
        case message
    }

    /*
     滚动代理
     */
    @State private var scrollViewProxy: ScrollViewProxy?

    var body: some View {
        NavigationStack {
            VStack {
                if isConnected {
                    if $messages.count > 1 {
                        ScrollViewReader { proxy in
                            ScrollView {
                                MessageListView(messages: $messages)
                                Text("").id(lastMessageTag)
                            }
                            .padding(0)
                            .onAppear {
                                scrollViewProxy = proxy
                            }
                        }
                    } else {
                        EmptyStatusView(message: "消息都被你删完了哦～")
                    }
                    FooterArea()
                } else {
                    SettingTipView()
                        .onTapGesture {
                            showSetting = true
                        }
                }
            }
            .onTapGesture {
                focusedField = nil
            }
            .onChange(
                of: focusedField,
                {
                    scrollToBottom()
                }
            )
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar(
                content: {
                    TopRightButton()
                })
        }
        .sheet(
            isPresented: $showSetting,
            onDismiss: {
                reloadConfig()
            },
            content: {
                SettingView()
            }
        )
        .sheet(
            isPresented: $showMessageHistory,
            onDismiss: {
                reloadMessage()
            },
            content: {
                MessageHistoryView()
            }
        )
        .onAppear {
            reloadConfig()
        }
    }

    /*
     输入框左侧菜单
     */
    private func InputLeftMenu() -> some View {
        return Menu {
            Button {
                MessageHistory.addToHistory(messages: messages)
                messages = []
                addSystemPromptMessage()
            } label: {
                Text("新的篇章")
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(
                        isRequesting ? .gray : .primary
                    )
            }
            .disabled(messages.count < 2)

            Button {
                showMessageHistory = true
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
                .frame(width: footerButtonSize, height: footerButtonSize)
        }
        .disabled(isRequesting)
    }

    /*
     输入框发送按钮
     */
    private func InputSendButton() -> some View {
        return Button(
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
                .frame(width: footerButtonSize, height: footerButtonSize)
                .foregroundStyle(
                    inputContent.isEmpty || isRequesting
                        ? .gray : .primary)
            }
        )
        .disabled(inputContent.isEmpty || isRequesting)
    }

    /*
     输入框
     */
    private func InputBox() -> some View {
        return TextField(
            isRequesting ? "思考中..." : "说点什么吧...",
            text: $inputContent
        )
        .focused($focusedField, equals: .message)
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
    }

    /*
     底部区域
     */
    private func FooterArea() -> some View {
        return HStack {
            InputLeftMenu()
            InputBox()
            InputSendButton()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
        .padding(.bottom, 10)
    }

    /*
     顶部右上角按钮
     */
    private func TopRightButton() -> ToolbarItem<(), some View> {
        return ToolbarItem(placement: .navigationBarTrailing) {
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
    }

    /*
     发送
     */
    private func send() async {
        if isRequesting {
            return
        }
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
        OllamaMessage.saveMessage(messages: messages)
        isRequesting = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusedField = .message
        }
    }

    /*
     滚动到底部
     */
    private func scrollToBottom() {
        scrollViewProxy?.scrollTo(lastMessageTag, anchor: .bottom)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            scrollViewProxy?.scrollTo(lastMessageTag, anchor: .bottom)
        }
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
        OllamaMessage.saveMessage(messages: messages)
    }

    /*
     重新加载消息
     */
    private func reloadMessage() {
        messages = OllamaMessage.getMessage()
        addSystemPromptMessage()
        scrollToBottom()
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
            reloadMessage()
        }
    }
}
