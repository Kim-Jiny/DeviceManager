//
//  LoginView.swift
//  DeviceManager
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    let onLoginSuccess: () -> Void
    let onSignUpTap: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Title
                VStack(spacing: 10) {
                    Text("로그인")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("회사 코드: \(viewModel.companyCode)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
                    .frame(height: 20)

                // Input Section
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("이메일")
                            .font(.headline)
                            .foregroundColor(.white)

                        DMTextField(
                            placeholder: "이메일 주소 입력",
                            text: $viewModel.email,
                            keyboardType: .emailAddress
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("비밀번호")
                            .font(.headline)
                            .foregroundColor(.white)

                        DMTextField(
                            placeholder: "비밀번호 입력",
                            text: $viewModel.password,
                            isSecure: true
                        )
                    }
                }
                .frame(width: 300)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                }

                Spacer()
                    .frame(height: 10)

                // Buttons
                VStack(spacing: 15) {
                    DMButton(
                        title: "로그인",
                        style: .outline,
                        action: {
                            Task {
                                await viewModel.login()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isInputValid
                    )
                    .frame(width: 300)
                }

                Spacer()

                // Footer
                VStack(spacing: 5) {
                    Text("가입된 계정이 없으신가요?")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("그룹 관리자에게 문의해주세요.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()
                    .frame(height: 30)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: viewModel.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                onLoginSuccess()
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        LoginView(
            viewModel: LoginViewModel(companyCode: "TEST"),
            onLoginSuccess: {},
            onSignUpTap: {},
            onBack: {}
        )
    }
}
