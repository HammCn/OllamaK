//
//  ConnectFirst.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct SettingTipView: View {
    var body: some View {
        Image(systemName: "wifi.router")
            .scaleEffect(3)
            .padding(.bottom,30)
            .foregroundStyle(.gray)
        Text("请先配置Ollama服务参数")
            .font(Font.system(size: 13))
            .foregroundColor(.gray)
    }
}

#Preview {
    SettingTipView()
}
