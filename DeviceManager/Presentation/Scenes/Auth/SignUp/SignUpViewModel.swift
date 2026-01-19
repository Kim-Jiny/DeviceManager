//
//  SignUpViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isRegistered: Bool = false

    let companyCode: String
    private let authRepository: AuthRepositoryProtocol

    init(
        companyCode: String,
        authRepository: AuthRepositoryProtocol = AuthRepository()
    ) {
        self.companyCode = companyCode
        self.authRepository = authRepository
    }

    var isInputValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty
    }

    var isPasswordMatch: Bool {
        password == confirmPassword
    }

    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    func signUp() async {
        guard isInputValid else {
            errorMessage = "모든 필드를 입력해주세요."
            return
        }

        guard isEmailValid else {
            errorMessage = "올바른 이메일 형식을 입력해주세요."
            return
        }

        guard isPasswordValid else {
            errorMessage = "비밀번호는 6자 이상이어야 합니다."
            return
        }

        guard isPasswordMatch else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authRepository.register(
                email: email.trimmingCharacters(in: .whitespaces),
                name: name.trimmingCharacters(in: .whitespaces),
                password: password
            )
            isRegistered = true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "회원가입 중 오류가 발생했습니다."
        }

        isLoading = false
    }
}
