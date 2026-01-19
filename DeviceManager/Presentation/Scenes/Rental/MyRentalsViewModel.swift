//
//  MyRentalsViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class MyRentalsViewModel: ObservableObject {
    @Published var rentals: [Rental] = []
    @Published var statistics: RentalStatistics?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private let limit: Int = 20

    private let rentalRepository: RentalRepositoryProtocol

    init(rentalRepository: RentalRepositoryProtocol = RentalRepository()) {
        self.rentalRepository = rentalRepository
    }

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    func loadRentals(reset: Bool = true) async {
        if reset {
            currentPage = 1
            isLoading = true
        }
        errorMessage = nil

        do {
            let response = try await rentalRepository.getMyRentals(
                page: currentPage,
                limit: limit,
                status: nil
            )

            if reset {
                rentals = response.rentals
            } else {
                rentals.append(contentsOf: response.rentals)
            }

            statistics = response.statistics
            totalPages = response.pagination.totalPages
            currentPage += 1

        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "대여 목록을 불러오는데 실패했습니다."
        }

        isLoading = false
    }

    func refresh() async {
        await loadRentals(reset: true)
    }
}
