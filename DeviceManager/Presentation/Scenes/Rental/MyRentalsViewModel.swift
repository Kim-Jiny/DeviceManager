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

    // Return functionality
    @Published var showReturnConfirmation: Bool = false
    @Published var selectedRentalForReturn: Rental?
    @Published var returningRentalId: Int?
    @Published var successMessage: String?

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

    // MARK: - Return Functionality

    func prepareReturn(_ rental: Rental) {
        selectedRentalForReturn = rental
        showReturnConfirmation = true
    }

    func returnRental() async {
        guard let rental = selectedRentalForReturn else { return }

        returningRentalId = rental.id
        errorMessage = nil

        do {
            try await rentalRepository.returnDevice(rentalId: rental.id, condition: nil)

            successMessage = "\(rental.device.name) 반납이 완료되었습니다."

            // Refresh to get updated list and statistics
            await loadRentals(reset: true)

        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "반납 처리에 실패했습니다."
        }

        returningRentalId = nil
        selectedRentalForReturn = nil
    }

    var canReturn: (Rental) -> Bool = { rental in
        rental.status == .approved || rental.status == .active
    }
}
