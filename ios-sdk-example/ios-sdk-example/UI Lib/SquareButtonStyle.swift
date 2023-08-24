//
//  SquareButtonStyle.swift
//  UITests
//
//  Created by Shai on 23/01/2023.
//

import SwiftUI

struct SquareButtonStyle: ButtonStyle {

    @State var color: Color = Color(hex: 0x8C1515)
    @State var size = CGFloat(12)
    @State var font:Font = .title.bold()
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
            .font(font)
            .padding(size)
            .frame(maxWidth: .infinity)
            .foregroundColor(isEnabled ? .white : Color(UIColor.systemGray3))
            .background(isEnabled ? color : Color(UIColor.systemGray5))
            .cornerRadius(12)
            .overlay {
                if configuration.isPressed {
                    Color(white: 1.0, opacity: 0.2)
                        .cornerRadius(12)
                }
            }
    }
}
