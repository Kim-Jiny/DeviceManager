//
//  AuthRepository.swift
//  DeviceManager
//

import Foundation

protocol AuthRepositoryProtocol {
    func validateCompany(code: String) async throws -> ValidateCompanyResponse
    func login(email: String, password: String) async throws -> LoginResponse
    func register(email: String, name: String, password: String) async throws -> RegisterResponse
    func refreshToken() async throws -> LoginResponse
    func logout()
}

final class AuthRepository: AuthRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol
    private let tokenStorage: TokenStorage

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared,
         tokenStorage: TokenStorage = .shared) {
        self.networkManager = networkManager
        self.tokenStorage = tokenStorage
    }

    func validateCompany(code: String) async throws -> ValidateCompanyResponse {
        struct ValidateRequest: Encodable {
            let code: String
        }

        let response: APIResponse<ValidateCompanyResponse> = try await networkManager.request(
            .validateCompany,
            body: ValidateRequest(code: code),
            queryParams: nil
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "회사 코드 검증에 실패했습니다.")
        }

        return data
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(email: email, password: password)

        let response: APIResponse<LoginResponse> = try await networkManager.request(
            .login,
            body: request,
            queryParams: nil
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "로그인에 실패했습니다.")
        }

        // Save token and user info
        tokenStorage.saveToken(data.token)
        tokenStorage.saveUser(data.user)

        return data
    }

    func register(email: String, name: String, password: String) async throws -> RegisterResponse {
        let request = RegisterRequest(email: email, name: name, password: password)

        let response: APIResponse<RegisterResponse> = try await networkManager.request(
            .register,
            body: request,
            queryParams: nil
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "회원가입에 실패했습니다.")
        }

        return data
    }

    func refreshToken() async throws -> LoginResponse {
        let response: APIResponse<LoginResponse> = try await networkManager.request(
            .refreshToken,
            body: nil as EmptyRequest?,
            queryParams: nil
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "토큰 갱신에 실패했습니다.")
        }

        tokenStorage.saveToken(data.token)
        tokenStorage.saveUser(data.user)

        return data
    }

    func logout() {
        tokenStorage.clearAll()
    }
}

// Helper for empty request body
private struct EmptyRequest: Encodable {}
