//
//  DMTextField.swift
//  DeviceManager
//

import SwiftUI

struct DMTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(25)
        .foregroundColor(.white)
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.DMColor.main.ignoresSafeArea()
        VStack(spacing: 20) {
            DMTextField(placeholder: "이메일", text: .constant(""))
            DMTextField(placeholder: "비밀번호", text: .constant(""), isSecure: true)
        }
        .padding()
    }
}
