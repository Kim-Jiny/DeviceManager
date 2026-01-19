//
//  TokenStorage.swift
//  DeviceManager
//

import Foundation
import Combine

/// 토큰 저장소 프로토콜
protocol TokenStorageProtocol: AnyObject {
    // Token
    func saveToken(_ token: String)
    func getToken() -> String?
    func clearToken()
    func isLoggedIn() -> Bool

    // User
    func saveUser(_ user: User)
    func getUser() -> User?
    func clearUser()

    // Company Code
    func saveCompanyCode(_ code: String)
    func getCompanyCode() -> String?
    func clearCompanyCode()

    // Clear All
    func clearAll()

    // Auth state publisher
    var authStatePublisher: AnyPublisher<Bool, Never> { get }
}

/// 토큰 및 사용자 정보 저장소
final class TokenStorage: TokenStorageProtocol {
    static let shared = TokenStorage()

    private let keychain = KeychainManager.shared
    private let tokenKey = "jwt_token"
    private let userKey = "current_user"
    private let companyCodeKey = "company_code"

    private let authStateSubject = CurrentValueSubject<Bool, Never>(false)

    var authStatePublisher: AnyPublisher<Bool, Never> {
        authStateSubject.eraseToAnyPublisher()
    }

    private init() {
        // 초기 로그인 상태 설정
        authStateSubject.send(getToken() != nil)
    }

    // MARK: - Token

    func saveToken(_ token: String) {
        _ = keychain.save(token, forKey: tokenKey)
        authStateSubject.send(true)
    }

    func getToken() -> String? {
        keychain.loadString(forKey: tokenKey)
    }

    func clearToken() {
        keychain.delete(forKey: tokenKey)
        authStateSubject.send(false)
    }

    func isLoggedIn() -> Bool {
        getToken() != nil
    }

    // MARK: - User

    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            _ = keychain.save(data, forKey: userKey)
        }
    }

    func getUser() -> User? {
        guard let data = keychain.load(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func clearUser() {
        keychain.delete(forKey: userKey)
    }

    // MARK: - Company Code

    func saveCompanyCode(_ code: String) {
        _ = keychain.save(code, forKey: companyCodeKey)
    }

    func getCompanyCode() -> String? {
        keychain.loadString(forKey: companyCodeKey)
    }

    func clearCompanyCode() {
        keychain.delete(forKey: companyCodeKey)
    }

    // MARK: - Clear All

    func clearAll() {
        clearToken()
        clearUser()
        clearCompanyCode()
    }

    // MARK: - Convenience

    /// 현재 사용자 이름 반환
    var currentUserName: String {
        getUser()?.name ?? "사용자"
    }

    /// 현재 회사 이름 반환
    var currentCompanyName: String {
        getUser()?.company?.name ?? "회사"
    }
}
