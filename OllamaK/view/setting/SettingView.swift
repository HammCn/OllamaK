//
//  ServiceConfig.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct SettingView: View {
    /*
     OllamaUrl
     */
    @State private var url = ""
    
    /*
     Ollama模型
     */
    @State private var model = ""
    
    /*
     系统Prompt
     */
    @State private var prompt = ""
    
    /*
     输入框焦点
     */
    @FocusState private var focusedField: Field?

    /*
     Ollama已返回
     */
    @State private var isOllamaRespond = false
    
    /*
     显示错误信息
     */
    @State private var showAlert = false
    
    /*
     错误信息
     */
    @State private var alertMessage = ""

    /*
     窗口
     */
    @Environment(\.presentationMode) var presentationMode

    /*
     可选模型列表
     */
    @State private var models: [OllamaModel] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ollama URL") {
                    TextField("Ollama URL...", text: $url)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .url)
                        .keyboardType(.URL)
                        .onChange(of: url) {
                            Task {
                                await getModels()
                            }
                        }
                        .onSubmit {
                            Task {
                                await getModels()
                            }
                        }
                }

                Section("系统提示词") {
                    TextEditor(text: $prompt)
                        .focused($focusedField, equals: .prompt)
                }

                Section("选择模型") {
                    Picker(selection: $model, label: Text("请选择")) {
                        ForEach(models) { model in
                            Text(model.name).tag(model.name)
                        }
                    }
                    .pickerStyle(.menu)
                }

            }
            .onChange(
                of: focusedField,
                {
                    if focusedField != .url {
                        Task {
                            await getModels()
                        }
                    }
                }
            )
            .navigationTitle("服务配置")
            .navigationBarTitleDisplayMode(.automatic)
            .onTapGesture {
                Task {
                    await getModels()
                }
            }
            .toolbar {
                TopRightButton()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"), message: Text(alertMessage),
                dismissButton: .default(Text("确定")))
        }
        .colorScheme(.dark)
        .onAppear {
            url = OllamaConfig.current?.url ?? "https://ollama.hamm.cn/"
            model = OllamaConfig.current?.model ?? ""
            prompt = OllamaConfig.current?.prompt ?? "你是个中文工作助理，擅长解决各种问题。"
            Task {
                await getModels()
            }
        }
    }
    
    /*
     顶部右上角按钮
     */
    private func TopRightButton() -> some View {
        return Button {
            let ollamaConfig = OllamaConfig.init(
                url: url, prompt: prompt, model: model, models: [])
            saveOllamaConfig(ollamaConfig: ollamaConfig)
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Text("保存")
        }
        .disabled(!isOllamaRespond || model.isEmpty)
        .foregroundStyle(
            !isOllamaRespond || model.isEmpty
            ? Color.gray : Color.primary)
    }
    
    /*
     输入焦点枚举
     */
    private enum Field {
        case url, prompt, model
    }
    
    /*
     保存当前配置
     */
    private func saveOllamaConfig(ollamaConfig: OllamaConfig) {
        guard
            let CONFIG_URL = try? FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask,
                appropriateFor: nil, create: false
            ).appendingPathComponent(OllamaConfig.CONFIG_PATH)
        else {
            print("无法获取文件路径")
            return
        }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(ollamaConfig)

            try data.write(to: CONFIG_URL, options: .atomic)
            OllamaConfig.current = ollamaConfig
        } catch {
            print("保存配置失败: \(error.localizedDescription)")
        }
    }
    
    /*
     获取模型列表
     */
    private func getModels() async {
        isOllamaRespond = false
        models = []
        // 发起网络请求
        do {
            models = try await OllamaConfig.getModels(url: url)
            if model.isEmpty {
                model = models[0].name
            } else if !models.contains(where: { $0.name == model }) {
                model = models[0].name
            }
            isOllamaRespond = true
        } catch {
            isOllamaRespond = false
        }
    }
}
