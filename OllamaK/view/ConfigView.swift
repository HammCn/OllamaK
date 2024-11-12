//
//  ServiceConfig.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct ConfigView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    ServiceConfigView()
                } label: {
                    HStack {
                        Image(systemName: "wifi.router")
                        VStack{
                            Text("服务网关配置")
                        }
                        Spacer()
                    }
                    .padding(.vertical,10)
                }
                NavigationLink {
                    ServiceConfigView()
                } label: {
                    HStack {
                        Image(systemName: "wifi.router")
                        VStack{
                            Text("服务网关配置")
                        }
                        Spacer()
                    }
                    .padding(.vertical,10)
                }
                NavigationLink {
                    ServiceConfigView()
                } label: {
                    HStack {
                        Image(systemName: "wifi.router")
                        VStack{
                            Text("服务网关配置")
                        }
                        Spacer()
                    }
                    .padding(.vertical,10)
                }
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ConfigView()
}
