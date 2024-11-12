//
//  ContentView.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct HomeView: View {
    private let  CONFIG_PATH = "config.json"
    @State private var content = ""
    private var title = "1"
    
    @State private var isConnected  = true
    @State private var showServiceSettings = false
    @State private var showConfig = false
    @State private var ollamaConfig: OllamaConfig?
    
    
    private func send()  {
        print("按钮被点击了")
    }
    
    private func getOllamaConfig(openDialog: Bool)  {
        guard let CONFIG_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(CONFIG_PATH) else {
            print("无法获取文件路径")
            return
        }
        do {
            // 从文件读取JSON数据
            let JSON_STRING = try Data(contentsOf: CONFIG_URL)
            
            // 解码JSON数据为OllamaConfig对象
            let OLLAMA_CONFIG = try JSONDecoder().decode(OllamaConfig.self, from: JSON_STRING)
            
            // 更新状态变量
            ollamaConfig = OLLAMA_CONFIG
        } catch {
            print("请先配置网关")
            if(openDialog){
                showServiceSettings = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if (isConnected) {
                    ScrollView {
                        Text("Hello")
                    }
                    HStack{
                        Button(action: send) {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.orange)
                        }
                        TextField("请输入内容", text: $content)
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
                            Image(systemName: "paperplane")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(content.isEmpty ? .gray : .orange)
                        }
                        .disabled(content.isEmpty)
                    }
                }else{
                    ConnectFirstView()
                        .onTapGesture {
                            showServiceSettings = true
                        }
                }
            }
            .padding()
            .navigationTitle(isConnected ? title : "OllamaK")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                Button {
                    showConfig = true
                } label: {
                    Image(systemName: "gear")
                        .scaleEffect(1)
                        .foregroundStyle(.orange)
                }
            })
            .navigationDestination(isPresented: $showServiceSettings) {
                ServiceConfigView()
            }
            .navigationDestination(isPresented: $showConfig) {
                ConfigView()
            }
        }
        .onAppear{
            getOllamaConfig(openDialog: true)
        }
    }
}

#Preview {
    HomeView()
}
