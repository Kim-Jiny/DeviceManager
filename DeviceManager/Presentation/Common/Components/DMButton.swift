//
//  DMButton.swift
//  DeviceManager
//

import SwiftUI

enum DMButtonStyle {
    case primary
    case secondary
    case outline
    case filled
}

struct DMButton: View {
    let title: String
    let style: DMButtonStyle
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(borderColor, lineWidth: style == .outline ? 1 : 0)
            )
        }
        .disabled(isLoading || isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.DMColor.white
        case .secondary:
            return Color.DMColor.main
        case .outline:
            return Color.clear
        case .filled:
            return Color.DMColor.main
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return Color.DMColor.main
        case .secondary, .outline:
            return Color.DMColor.white
        case .filled:
            return Color.DMColor.white
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return Color.DMColor.white
        default:
            return Color.clear
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.DMColor.main.ignoresSafeArea()
        VStack(spacing: 20) {
            DMButton(title: "Primary", style: .primary, action: {})
            DMButton(title: "Secondary", style: .secondary, action: {})
            DMButton(title: "Outline", style: .outline, action: {})
            DMButton(title: "Loading", style: .primary, action: {}, isLoading: true)
            DMButton(title: "Disabled", style: .primary, action: {}, isDisabled: true)
        }
        .padding()
    }
}
