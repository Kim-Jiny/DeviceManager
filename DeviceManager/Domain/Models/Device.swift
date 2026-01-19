//
//  Device.swift
//  DeviceManager
//

import Foundation

// MARK: - Device Model
struct Device: Codable, Identifiable {
    let id: Int
    let companyId: Int
    let name: String
    let model: String
    let serialNumber: String
    let deviceToken: String?
    let categoryId: Int?
    let categoryName: String?
    let status: DeviceStatus
    let purchaseDate: String?
    let warrantyEndDate: String?
    let description: String?
    let imageUrl: String?
    let specs: DeviceSpecs?
    let isFavorite: Bool?
    let currentRental: CurrentRental?
    let createdAt: String?
    let updatedAt: String?
}

// MARK: - Device Status
enum DeviceStatus: String, Codable, CaseIterable {
    case available = "AVAILABLE"
    case rented = "RENTED"
    case maintenance = "MAINTENANCE"
    case retired = "RETIRED"

    var displayName: String {
        switch self {
        case .available:
            return "대여 가능"
        case .rented:
            return "대여 중"
        case .maintenance:
            return "점검 중"
        case .retired:
            return "폐기"
        }
    }

    var color: String {
        switch self {
        case .available:
            return "green"
        case .rented:
            return "orange"
        case .maintenance:
            return "yellow"
        case .retired:
            return "gray"
        }
    }
}

// MARK: - Device Specs
struct DeviceSpecs: Codable {
    let cpu: String?
    let ram: String?
    let storage: String?
    let display: String?
    let os: String?
    let additionalInfo: [String: String]?
}

// MARK: - Current Rental
struct CurrentRental: Codable {
    let userId: Int
    let userName: String?
    let endDate: String?
    let actualEndDate: String?
}

// MARK: - Device List Response
struct DeviceListResponse: Decodable {
    let devices: [Device]
    let pagination: Pagination
}
