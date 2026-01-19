//
//  RentalRepository.swift
//  DeviceManager
//

import Foundation

protocol RentalRepositoryProtocol {
    func requestRental(deviceId: Int, startDate: String, endDate: String, notes: String?) async throws -> RentalRequestResponse
    func getMyRentals(page: Int, limit: Int, status: RentalStatus?) async throws -> MyRentalsResponse
    func returnDevice(rentalId: Int, condition: String?) async throws
}

final class RentalRepository: RentalRepositoryProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    func requestRental(
        deviceId: Int,
        startDate: String,
        endDate: String,
        notes: String?
    ) async throws -> RentalRequestResponse {
        let request = RentalRequest(
            deviceId: deviceId,
            requestedStartDate: startDate,
            requestedEndDate: endDate,
            notes: notes
        )

        let response: APIResponse<RentalRequestResponse> = try await networkManager.request(
            .rentalRequest,
            body: request,
            queryParams: nil
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "대여 신청에 실패했습니다.")
        }

        return data
    }

    func getMyRentals(
        page: Int = 1,
        limit: Int = 20,
        status: RentalStatus? = nil
    ) async throws -> MyRentalsResponse {
        var queryParams: [String: String] = [
            "page": String(page),
            "limit": String(limit)
        ]

        if let status = status {
            queryParams["status"] = status.rawValue
        }

        let response: APIResponse<MyRentalsResponse> = try await networkManager.request(
            .myRentals,
            body: nil as EmptyRequest?,
            queryParams: queryParams
        )

        guard response.success, let data = response.data else {
            throw NetworkError.serverError(response.message ?? "대여 목록을 불러오는데 실패했습니다.")
        }

        return data
    }

    func returnDevice(rentalId: Int, condition: String?) async throws {
        struct ReturnRequest: Encodable {
            let rentalId: Int
            let returnCondition: String?

            enum CodingKeys: String, CodingKey {
                case rentalId = "rental_id"
                case returnCondition = "return_condition"
            }
        }

        let response: APIResponse<EmptyResponse> = try await networkManager.request(
            .returnDevice,
            body: ReturnRequest(rentalId: rentalId, returnCondition: condition),
            queryParams: nil
        )

        guard response.success else {
            throw NetworkError.serverError(response.message ?? "반납 처리에 실패했습니다.")
        }
    }
}

// Helper for empty request body
private struct EmptyRequest: Encodable {}
