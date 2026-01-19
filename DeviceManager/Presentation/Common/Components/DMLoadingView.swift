//
//  DMLoadingView.swift
//  DeviceManager
//

import SwiftUI

struct DMLoadingView: View {
    var message: String = "로딩 중..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.DMColor.white))
                .scaleEffect(1.5)

            Text(message)
                .font(.subheadline)
                .foregroundColor(Color.DMColor.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.DMColor.main.opacity(0.8))
    }
}

// MARK: - Error View
struct DMErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text(message)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Button("다시 시도") {
                retryAction()
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.white)
            .foregroundColor(Color.DMColor.main)
            .cornerRadius(25)
        }
        .padding()
    }
}

// MARK: - Empty State View
struct DMEmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.DMColor.main.ignoresSafeArea()
        VStack(spacing: 40) {
            DMLoadingView()
                .frame(height: 100)

            DMErrorView(message: "네트워크 오류가 발생했습니다.") {}
                .frame(height: 200)

            DMEmptyStateView(
                icon: "tray",
                title: "데이터 없음",
                message: "표시할 항목이 없습니다."
            )
        }
    }
}
