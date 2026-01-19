//
//  LoginViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var formState = FormState()

    // MARK: - Properties

    let companyCode: String
    private let authRepository: AuthRepositoryProtocol

    // MARK: - Computed Properties

    var isLoading: Bool { formState.isSubmitting }
    var errorMessage: String? { formState.errorMessage }
    var isLoggedIn: Bool { formState.isSuccess }

    var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespaces).lowercased()
    }

    var isInputValid: Bool {
        !trimmedEmail.isEmpty && !password.isEmpty
    }

    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: trimmedEmail)
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    // MARK: - Initialization

    init(
        companyCode: String,
        authRepository: AuthRepositoryProtocol = AuthRepository()
    ) {
        self.companyCode = companyCode
        self.authRepository = authRepository
    }

    // MARK: - Public Methods

    func login() async {
        // 입력 유효성 검사
        guard isInputValid else {
            formState.failure("이메일과 비밀번호를 입력해주세요.")
            return
        }

        guard isEmailValid else {
            formState.failure("올바른 이메일 형식을 입력해주세요.")
            return
        }

        guard isPasswordValid else {
            formState.failure("비밀번호는 6자 이상이어야 합니다.")
            return
        }

        formState.startSubmitting()

        do {
            _ = try await authRepository.login(
                email: trimmedEmail,
                password: password
            )
            formState.success()
        } catch let error as NetworkError {
            formState.failure(error.localizedDescription)
        } catch {
            formState.failure("로그인 중 오류가 발생했습니다.")
        }
    }

    func reset() {
        email = ""
        password = ""
        formState.reset()
    }
}
