//
//  ServiceConfig.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct ServiceConfigView: View {
    var body: some View {
        NavigationView {
            VStack{
                // 输入
            }
        }
        .navigationTitle("服务网关")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                
            } label: {
                Text("保存")
                    .foregroundColor(.orange)
            }
        }
    }
}

#Preview {
    ServiceConfigView()
}
