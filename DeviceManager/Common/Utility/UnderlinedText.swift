//
//  UnderlinedText.swift
//  DeviceManager
//
//  Created by 김미진 on 11/26/23.
//

import Foundation

import SwiftUI
struct UnderlinedText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.DMColor.white) // 밑줄 색상 지정
                }
            )
    }
}

extension View {
    func underline() -> some View {
        self.modifier(UnderlinedText())
    }
}
