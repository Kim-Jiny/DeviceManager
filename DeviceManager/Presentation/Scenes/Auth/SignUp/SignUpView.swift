//
//  SignUpView.swift
//  DeviceManager
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel: SignUpViewModel
    let onSignUpSuccess: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    Spacer()
                        .frame(height: 30)

                    // Title
                    Text("회원가입")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()
                        .frame(height: 20)

                    // Input Fields
                    VStack(alignment: .leading, spacing: 20) {
                        InputField(title: "이름", placeholder: "이름 입력", text: $viewModel.name)
                        InputField(title: "이메일", placeholder: "이메일 주소 입력", text: $viewModel.email, keyboardType: .emailAddress)
                        InputField(title: "비밀번호", placeholder: "6자 이상 입력", text: $viewModel.password, isSecure: true)
                        InputField(title: "비밀번호 확인", placeholder: "비밀번호 다시 입력", text: $viewModel.confirmPassword, isSecure: true)
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
                        .frame(height: 20)

                    DMButton(
                        title: "가입하기",
                        style: .outline,
                        action: {
                            Task {
                                await viewModel.signUp()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isInputValid
                    )
                    .frame(width: 300)

                    Spacer()
                        .frame(height: 50)
                }
                .padding()
            }
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
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onChange(of: viewModel.isRegistered) { _, isRegistered in
            if isRegistered {
                onSignUpSuccess()
            }
        }
    }
}

// MARK: - Input Field Component
private struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            DMTextField(
                placeholder: placeholder,
                text: $text,
                isSecure: isSecure,
                keyboardType: keyboardType
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SignUpView(
            viewModel: SignUpViewModel(companyCode: "TEST"),
            onSignUpSuccess: {},
            onBack: {}
        )
    }
}
