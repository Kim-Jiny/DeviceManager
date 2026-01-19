//
//  Rental.swift
//  DeviceManager
//

import Foundation

// MARK: - Rental Model
struct Rental: Codable, Identifiable {
    let id: Int
    let status: RentalStatus
    let requestedStartDate: String
    let requestedEndDate: String
    let actualStartDate: String?
    let actualEndDate: String?
    let notes: String?
    let rejectionReason: String?
    let returnCondition: String?
    let createdAt: String
    let updatedAt: String?
    let device: RentalDevice
    let approver: RentalApprover?
    let durationDays: Int?
    let isOverdue: Bool?
    let daysRemaining: Int?
    let canReturn: Bool?
    let canExtend: Bool?
    let canCancel: Bool?
}

// MARK: - Rental Status
enum RentalStatus: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case rejected = "REJECTED"
    case active = "ACTIVE"
    case returned = "RETURNED"
    case cancelled = "CANCELLED"

    var displayName: String {
        switch self {
        case .pending:
            return "승인 대기"
        case .approved:
            return "승인됨"
        case .rejected:
            return "거절됨"
        case .active:
            return "대여 중"
        case .returned:
            return "반납 완료"
        case .cancelled:
            return "취소됨"
        }
    }
}

// MARK: - Rental Device
struct RentalDevice: Codable {
    let id: Int
    let name: String
    let model: String?
    let serialNumber: String?
    let imageUrl: String?
    let status: String?
    let categoryName: String?
}

// MARK: - Rental Approver
struct RentalApprover: Codable {
    let id: Int
    let name: String
}

// MARK: - Rental Request
struct RentalRequest: Encodable {
    let deviceId: Int
    let requestedStartDate: String
    let requestedEndDate: String
    let notes: String?
}

// MARK: - Rental Response
struct RentalRequestResponse: Decodable {
    let rentalId: Int
    let status: String
}

// MARK: - My Rentals Response
struct MyRentalsResponse: Decodable {
    let rentals: [Rental]
    let pagination: Pagination
    let statistics: RentalStatistics
    let userInfo: RentalUserInfo
}

// MARK: - Rental Statistics
struct RentalStatistics: Decodable {
    let byStatus: [String: Int]
    let totalRentals: Int
    let activeRentals: Int
    let overdueCount: Int
}

// MARK: - Rental User Info
struct RentalUserInfo: Decodable {
    let id: Int
    let name: String
    let email: String
}
