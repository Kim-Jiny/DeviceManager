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
    let pendingRental: PendingRental?
    let createdAt: String?
    let updatedAt: String?

    var hasPendingRental: Bool {
        pendingRental != nil
    }

    var isMyPendingRental: Bool {
        pendingRental?.isMine ?? false
    }
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

// MARK: - Device Specs (동적 key-value 지원)
struct DeviceSpecs: Codable {
    private var storage: [String: String] = [:]

    var allSpecs: [(key: String, value: String)] {
        storage.sorted { $0.key < $1.key }
    }

    var isEmpty: Bool {
        storage.isEmpty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dict = try? container.decode([String: String].self) {
            storage = dict
        } else if let dict = try? container.decode([String: AnyCodableValue].self) {
            storage = dict.compactMapValues { $0.stringValue }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }

    subscript(key: String) -> String? {
        storage[key]
    }
}

// Helper for decoding mixed JSON values
struct AnyCodableValue: Codable {
    let value: Any

    var stringValue: String? {
        if let str = value as? String { return str }
        if let num = value as? Int { return String(num) }
        if let num = value as? Double { return String(num) }
        if let bool = value as? Bool { return bool ? "Yes" : "No" }
        return nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            value = str
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let str = value as? String {
            try container.encode(str)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        }
    }
}

// MARK: - Current Rental
struct CurrentRental: Codable {
    let userId: Int
    let userName: String?
    let endDate: String?
    let actualEndDate: String?
}

// MARK: - Pending Rental
struct PendingRental: Codable {
    let rentalId: Int
    let userId: Int
    let userName: String?
    let status: String
    let isMine: Bool

    var statusDisplay: String {
        switch status {
        case "PENDING":
            return isMine ? "내 신청 대기" : "신청 대기 중"
        case "APPROVED":
            return isMine ? "내 대여 승인됨" : "대여 승인됨"
        case "ACTIVE":
            return isMine ? "내가 사용 중" : "사용 중"
        default:
            return status
        }
    }

    var statusColor: String {
        switch status {
        case "PENDING":
            return "orange"
        case "APPROVED":
            return "blue"
        case "ACTIVE":
            return "green"
        default:
            return "gray"
        }
    }
}

// MARK: - Device List Response
struct DeviceListResponse: Decodable {
    let devices: [Device]
    let pagination: Pagination
}
