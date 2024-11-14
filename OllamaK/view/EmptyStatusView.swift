//
//  ConnectFirst.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/12.
//

import SwiftUI

struct EmptyStatusView: View {
    /*
     空白消息
     */
    public var message: String = "Error"

    var body: some View {
        Spacer()
        Image(systemName: "moon.stars")
            .scaleEffect(3)
            .padding(.bottom, 30)
            .foregroundStyle(.gray)
        Text(message)
            .font(Font.system(size: 14))
            .foregroundColor(.gray)
        Spacer()
    }
}
