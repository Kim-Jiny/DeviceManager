//
//  CompanyNumberView.swift
//  DeviceManager
//

import SwiftUI

struct CompanyNumberView: View {
    @StateObject var viewModel: CompanyNumberViewModel
    let onValidCompany: (String) -> Void

    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Logo or Title
                VStack(spacing: 10) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    Text("Device Manager")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("회사 코드를 입력해주세요")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()
                    .frame(height: 30)

                // Input Section
                VStack(spacing: 20) {
                    DMTextField(
                        placeholder: "회사 코드 입력",
                        text: $viewModel.companyCode
                    )
                    .frame(width: 300)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    if let companyInfo = viewModel.companyInfo {
                        VStack(spacing: 8) {
                            Text("회사 확인됨")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(companyInfo.name)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }

                    DMButton(
                        title: viewModel.isValidated ? "로그인으로 이동" : "확인",
                        style: .outline,
                        action: {
                            if viewModel.isValidated {
                                onValidCompany(viewModel.companyCode)
                            } else {
                                Task {
                                    await viewModel.validateCompany()
                                }
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isInputValid
                    )
                    .frame(width: 300)
                }

                Spacer()

                // Footer
                Text("문의: support@devicemanager.com")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                Spacer()
                    .frame(height: 30)
            }
            .padding()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: viewModel.companyCode) { _, _ in
            // 코드가 변경되면 검증 상태만 리셋 (입력 내용 유지)
            if viewModel.isValidated {
                viewModel.clearValidation()
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    CompanyNumberView(
        viewModel: CompanyNumberViewModel(),
        onValidCompany: { _ in }
    )
}
