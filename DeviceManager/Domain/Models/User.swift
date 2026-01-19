//
//  User.swift
//  DeviceManager
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: UserRole
    let hasCompany: Bool?
    let company: UserCompany?
}

// MARK: - User Role
enum UserRole: String, Codable {
    case user = "USER"
    case companyManager = "COMPANY_MANAGER"
    case companyAdmin = "COMPANY_ADMIN"
    case systemAdmin = "SYSTEM_ADMIN"

    var displayName: String {
        switch self {
        case .user:
            return "일반 사용자"
        case .companyManager:
            return "매니저"
        case .companyAdmin:
            return "관리자"
        case .systemAdmin:
            return "시스템 관리자"
        }
    }

    var isManager: Bool {
        switch self {
        case .companyManager, .companyAdmin, .systemAdmin:
            return true
        case .user:
            return false
        }
    }

    var isAdmin: Bool {
        switch self {
        case .companyAdmin, .systemAdmin:
            return true
        case .user, .companyManager:
            return false
        }
    }
}

// MARK: - User Company
struct UserCompany: Codable {
    let id: Int
    let name: String
    let code: String
}

// MARK: - Login Request/Response
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
    let user: User
}

// MARK: - Register Request
struct RegisterRequest: Encodable {
    let email: String
    let name: String
    let password: String
}

struct RegisterResponse: Decodable {
    let userId: Int?
    let message: String?
}

// MARK: - Validate Company Response
struct ValidateCompanyResponse: Decodable {
    let company: CompanyInfo
    let isValid: Bool
}

struct CompanyInfo: Decodable {
    let id: Int
    let name: String
    let code: String
    let domain: String?
    let subscriptionStatus: String?
}
