//
//  MessageView.swift
//  PokeExampleUiKIT
//
//  Created by Carlos Paredes on 12/7/24.
//

import SwiftUI

enum MessageType {
    case success
    case normal
    case error
}

struct MessageView: View {
    
    let title: String
    let message: String
    let messageType: MessageType
    
    private var backgroundColor: Color {
        switch messageType {
        case .success:
            Color.green
        case .normal:
            Color.orange
        case .error:
            Color.red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(message)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.white)
        .padding()
        .background {
            backgroundColor
        }
        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
        .padding()
    }
}

#Preview {
    MessageView(title: "error", message: "unable to load producs", messageType: .normal)
}
