//
//  ContentView.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct HomeView: View {
    @State private var title = "Hi OllamaK!"
    @State private var isConnected  = true
    @State private var showSetting = false
    
    @State private var messages: [OllamaMessage] = []
    
    @State private var isRequesting  = false
    @State private var inputContent = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if (isConnected) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            MessageListView(messages: $messages)
                            Text("").id("message-list")
                        }
                        .padding(0)
                        .onAppear(){
                            scrollViewProxy = proxy
                        }
                    }
                    HStack{
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
                            Task{
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
                                Task{
                                    await send()
                                }
                            },
                            label: {
                                Image(
                                    systemName: isRequesting ? "ellipsis.circle" : "chevron.up.circle.fill"
                                )
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(inputContent.isEmpty || isRequesting ? .gray : .primary)
                            }
                        )
                        .disabled(inputContent.isEmpty || isRequesting)
                    }
                    .padding(.horizontal,15)
                    .padding(.vertical, 5)
                    .padding(.bottom,10)
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
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button(action: {
//                            showSetting = true
//                        }) {
//                            Image(systemName: "clock.badge")
//                                .resizable()
//                                .frame(width: 24, height: 24)
//                                .scaleEffect(1)
//                        }
//                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                showSetting = true
                            }) {
                                HStack{
                                    Text("服务配置")
                                    Image(systemName: "wifi.router")
                                }
                            }
                            Button(
                                action: {
                                    let url = URL(
                                        string: "https://github.com/HammCn/OllamaK"
                                    )!
                                    UIApplication.shared.open(url)
                                }) {
                                    HStack{
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
            .sheet(isPresented: $showSetting, onDismiss: {
                reloadConfig()
            }, content: {
                SettingView()
            })
        }
        .onAppear{
            reloadConfig()
        }
    }
    
    private func send() async {
        isRequesting = true
        messages
            .append(
                OllamaMessage.init(
                    role: OllamaMessage.ROLE_USER,
                    content: inputContent
                )
            )
        inputContent = ""
        messages
            .append(
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
            let stream: AsyncThrowingStream = try await StreamRequestUtil.request(
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
    
    private func scrollToBottom() {
        scrollViewProxy?.scrollTo("message-list", anchor: .bottom)
    }
    
    @State private var scrollViewProxy: ScrollViewProxy?
    
    private func addSystemPromptMessage(){
        if(messages.isEmpty){
            messages
                .append(
                    OllamaMessage.init(
                        role: OllamaMessage.ROLE_SYSTEM,
                        content: OllamaConfig.current!.prompt
                    )
                )
        }
    }
    
    private func reloadConfig(){
        print("加载配置")
        Task{
            isConnected = false
            let config = await OllamaConfig.getConfig()
            if(config == nil){
                showSetting = true
                return
            }
            title = OllamaConfig.current!.model
            isConnected = true
            addSystemPromptMessage()
        }
    }
}
