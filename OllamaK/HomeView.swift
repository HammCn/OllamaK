//
//  ContentView.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct HomeView: View {
    @State private var content = ""
    @State private var title = "Hi OllamaK!"
    @State private var isConnected  = true
    @State private var showSetting = false
    @State private var showSelectModel = false
    @State private var messages: [OllamaMessage] = []
    @State private var models: [OllamaModel] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                if (isConnected) {
                    ScrollView {
                        ForEach(messages){message in
                            if(message.role == OllamaMessage.ROLE_ASSISTANT) {
                                MessageAssistantView()
                            }
                        }
                        Spacer()
                    }
                    HStack{
                        Button(action: send) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        TextField("你可以和我聊任何事情...", text: $content)
                            .onSubmit(send)
                            .submitLabel(.send)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                            .padding(.horizontal, 5)
                        
                        Button(action: send) {
                            Image(systemName: "chevron.up.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(content.isEmpty ? .gray : .primary)
                        }
                        .disabled(content.isEmpty)
                    }
                }else{
                    SettingTipView()
                        .onTapGesture {
                            showSetting = true
                        }
                }
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSetting = true
                    }) {
                        Image(systemName: "clock.badge")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .scaleEffect(1)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showSetting = true
                        }) {
                            HStack{
                                Text("Setting")
                                Image(systemName: "gear")
                            }
                        }
                        Button(action: {
                            showSetting = true
                        }) {
                            HStack{
                                Text("About")
                                Image(systemName: "questionmark.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .scaleEffect(1)
                    }
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
    
    
    
    private func send()  {
        print("按钮被点击了")
        messages.append(OllamaMessage.init(role: OllamaMessage.ROLE_USER,content: content))
        // 发请求到 ollama 服务
        let request = OllamaRequest(model: title, messages: messages)
        print(request)
        
    }
    
    private func reloadConfig(){
        print("加载配置")
        Task{
            let config = await OllamaConfig.getConfig()
            if(config == nil){
                showSetting = true
                return
            }
            models = config?.models ?? []
            title = OllamaConfig.current!.model
        }
    }
}

#Preview {
    HomeView()
}
