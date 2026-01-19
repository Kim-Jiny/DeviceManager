//
//  DeviceRepository.swift
//  DeviceManager
//

import Foundation

protocol DeviceRepositoryProtocol {
    func getDevices(page: Int, limit: Int, search: String?, status: DeviceStatus?, categoryId: Int?) async throws -> DeviceListResponse
    func getDeviceDetail(id: Int) async throws -> Device
    func getCategories() async throws -> [Category]
}

final class DeviceRepository: DeviceRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    func getDevices(
        page: Int = 1,
        limit: Int = 12,
        search: String? = nil,
        status: DeviceStatus? = nil,
        categoryId: Int? = nil
    ) async throws -> DeviceListResponse {
        var queryParams: [String: String] = [
            "page": String(page),
            "limit": String(limit)
        ]

        if let search = search, !search.isEmpty {
            queryParams["search"] = search
        }

        if let status = status {
            queryParams["status"] = status.rawValue
        }

        if let categoryId = categoryId, categoryId > 0 {
            queryParams["category_id"] = String(categoryId)
        }

        let response: APIResponse<DeviceListResponse> = try await networkManager.request(
            .deviceList,
            body: nil as EmptyRequest?,
            queryParams: queryParams
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "디바이스 목록을 불러오는데 실패했습니다.")
        }

        return data
    }

    func getDeviceDetail(id: Int) async throws -> Device {
        let response: APIResponse<Device> = try await networkManager.request(
            .deviceDetail(id: id),
            body: nil as EmptyRequest?,
            queryParams: nil
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "디바이스 정보를 불러오는데 실패했습니다.")
        }

        return data
    }

    func getCategories() async throws -> [Category] {
        let response: APIResponse<CategoryListResponse> = try await networkManager.request(
            .categories,
            body: nil as EmptyRequest?,
            queryParams: nil
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "카테고리를 불러오는데 실패했습니다.")
        }

        return data.categories
    }
}

// Helper for empty request body
private struct EmptyRequest: Encodable {}
