//
//  APIResponse.swift
//  DeviceManager
//

import Foundation

// MARK: - Generic API Response
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?
    let timestamp: String?
}

// MARK: - Empty Response
struct EmptyResponse: Decodable {}

// MARK: - Pagination
struct Pagination: Decodable {
    let page: Int?
    let currentPage: Int?
    let limit: Int
    let total: Int?
    let totalCount: Int?
    let totalPages: Int
    let hasNext: Bool?
    let hasPrev: Bool?

    var actualPage: Int {
        return page ?? currentPage ?? 1
    }

    var actualTotal: Int {
        return total ?? totalCount ?? 0
    }
}
