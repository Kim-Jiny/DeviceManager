//
//  CompanyNumberViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class CompanyNumberViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var companyCode: String = ""
    @Published private(set) var formState = FormState()
    @Published private(set) var companyInfo: CompanyInfo?

    // MARK: - Private Properties

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Computed Properties

    var isLoading: Bool { formState.isSubmitting }
    var errorMessage: String? { formState.errorMessage }
    var isValidated: Bool { formState.isSuccess }

    var isInputValid: Bool {
        companyCode.trimmingCharacters(in: .whitespaces).count >= 2
    }

    var trimmedCode: String {
        companyCode.trimmingCharacters(in: .whitespaces).uppercased()
    }

    // MARK: - Initialization

    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }

    // MARK: - Public Methods

    func validateCompany() async {
        guard isInputValid else {
            formState.failure("회사 코드를 입력해주세요.")
            return
        }

        formState.startSubmitting()

        do {
            let response = try await authRepository.validateCompany(code: trimmedCode)
            companyInfo = response.company
            formState.success()
        } catch let error as NetworkError {
            formState.failure(error.localizedDescription)
        } catch {
            formState.failure("회사 코드 확인 중 오류가 발생했습니다.")
        }
    }

    func reset() {
        companyCode = ""
        formState.reset()
        companyInfo = nil
    }

    func clearValidation() {
        formState.reset()
        companyInfo = nil
    }
}
