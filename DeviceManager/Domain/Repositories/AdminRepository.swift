//
//  AdminRepository.swift
//  DeviceManager
//

import Foundation

// MARK: - Admin Rental Models

struct AdminRentalListResponse: Decodable {
    let rentals: [AdminRental]
    let pagination: Pagination
    let statistics: AdminRentalStatistics
}

struct AdminRental: Codable, Identifiable {
    let id: Int
    let status: String
    let requestedStartDate: String?
    let requestedEndDate: String?
    let actualStartDate: String?
    let actualEndDate: String?
    let notes: String?
    let rejectionReason: String?
    let createdAt: String?
    let updatedAt: String?
    let device: AdminRentalDevice
    let user: AdminRentalUser
    let approver: AdminRentalApprover?

    var statusDisplay: String {
        switch status {
        case "PENDING": return "승인 대기"
        case "APPROVED": return "승인됨"
        case "REJECTED": return "거절됨"
        case "ACTIVE": return "사용 중"
        case "RETURNED": return "반납 완료"
        default: return status
        }
    }

    var statusColor: String {
        switch status {
        case "PENDING": return "orange"
        case "APPROVED": return "blue"
        case "REJECTED": return "red"
        case "ACTIVE": return "green"
        case "RETURNED": return "gray"
        default: return "gray"
        }
    }
}

struct AdminRentalDevice: Codable {
    let id: Int
    let name: String
    let model: String
    let serialNumber: String?
    let imageUrl: String?
    let status: String
}

struct AdminRentalUser: Codable {
    let id: Int
    let name: String
    let email: String
}

struct AdminRentalApprover: Codable {
    let name: String
}

struct AdminRentalStatistics: Codable {
    let pending: Int
    let approved: Int
    let rejected: Int
    let active: Int
    let returned: Int
}

// MARK: - User Management Models

struct CompanyUserListResponse: Decodable {
    let users: [CompanyUser]
    let pagination: Pagination
    let statistics: UserStatistics
}

struct CompanyUser: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: String
    let isActive: Bool
    let activeRentalsCount: Int
    let totalRentalsCount: Int
    let createdAt: String?
    let updatedAt: String?

    var roleDisplay: String {
        switch role {
        case "COMPANY_ADMIN":
            return "관리자"
        case "COMPANY_MANAGER":
            return "매니저"
        default:
            return "일반 사용자"
        }
    }

    var canChangeRole: Bool {
        return role != "COMPANY_ADMIN"
    }
}

struct UserStatistics: Codable {
    let user: Int
    let companyManager: Int
    let companyAdmin: Int
}

// MARK: - Request Models

struct ProcessRentalRequest: Encodable {
    let action: String
    let rejectionReason: String?

    enum CodingKeys: String, CodingKey {
        case action
        case rejectionReason = "rejection_reason"
    }
}

struct UpdateDeviceStatusRequest: Encodable {
    let status: String
    let note: String?
}

struct UpdateUserRoleRequest: Encodable {
    let role: String
}

// MARK: - Admin Repository

final class AdminRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    // MARK: - Rental Management

    func getPendingRentals(status: String = "PENDING", page: Int = 1, limit: Int = 20) async throws -> APIResponse<AdminRentalListResponse> {
        let queryParams = [
            "status": status,
            "page": String(page),
            "limit": String(limit)
        ]
        return try await networkManager.request(.pendingRentals, body: nil, queryParams: queryParams)
    }

    func processRental(rentalId: Int, action: String, rejectionReason: String? = nil) async throws -> APIResponse<EmptyResponse> {
        let body = ProcessRentalRequest(action: action, rejectionReason: rejectionReason)
        return try await networkManager.request(.processRental(id: rentalId), body: body, queryParams: nil)
    }

    // MARK: - Device Status Management

    func updateDeviceStatus(deviceId: Int, status: String, note: String? = nil) async throws -> APIResponse<EmptyResponse> {
        let body = UpdateDeviceStatusRequest(status: status, note: note)
        return try await networkManager.request(.updateDeviceStatus(id: deviceId), body: body, queryParams: nil)
    }

    // MARK: - User Management

    func getCompanyUsers(page: Int = 1, limit: Int = 20, search: String? = nil, role: String? = nil) async throws -> APIResponse<CompanyUserListResponse> {
        var queryParams: [String: String] = [
            "page": String(page),
            "limit": String(limit)
        ]

        if let search = search, !search.isEmpty {
            queryParams["search"] = search
        }

        if let role = role, !role.isEmpty {
            queryParams["role"] = role
        }

        return try await networkManager.request(.userList, body: nil, queryParams: queryParams)
    }

    func updateUserRole(userId: Int, newRole: String) async throws -> APIResponse<EmptyResponse> {
        let body = UpdateUserRoleRequest(role: newRole)
        return try await networkManager.request(.updateUserRole(id: userId), body: body, queryParams: nil)
    }
}
