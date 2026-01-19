//
//  AdminRentalsViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class AdminRentalsViewModel: ObservableObject {
    @Published var rentals: [AdminRental] = []
    @Published var statistics: AdminRentalStatistics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedStatus: String = "PENDING"
    @Published var showRejectionAlert = false
    @Published var rejectionReason = ""
    @Published var selectedRentalForRejection: AdminRental?
    @Published var processingRentalId: Int?
    @Published var successMessage: String?

    private let repository: AdminRepository
    private var currentPage = 1
    private var totalPages = 1

    let statusFilters = [
        ("PENDING", "대기 중"),
        ("APPROVED", "승인됨"),
        ("ACTIVE", "사용 중"),
        ("RETURNED", "반납 완료"),
        ("REJECTED", "거절됨"),
        ("ALL", "전체")
    ]

    init(repository: AdminRepository = AdminRepository()) {
        self.repository = repository
    }

    func loadRentals() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await repository.getPendingRentals(status: selectedStatus, page: currentPage, limit: 20)
            if response.success, let data = response.data {
                rentals = data.rentals
                statistics = data.statistics
                totalPages = data.pagination.totalPages
            } else {
                errorMessage = response.message ?? "데이터를 불러올 수 없습니다."
            }
        } catch {
            errorMessage = "오류: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadMore() async {
        guard currentPage < totalPages, !isLoading else { return }

        currentPage += 1
        do {
            let response = try await repository.getPendingRentals(status: selectedStatus, page: currentPage, limit: 20)
            if response.success, let data = response.data {
                rentals.append(contentsOf: data.rentals)
            }
        } catch {
            currentPage -= 1
        }
    }

    func approveRental(_ rental: AdminRental) async {
        processingRentalId = rental.id
        errorMessage = nil

        do {
            let response = try await repository.processRental(rentalId: rental.id, action: "approve")
            if response.success {
                successMessage = "대여가 승인되었습니다."
                await loadRentals()
            } else {
                errorMessage = response.message ?? "승인 처리에 실패했습니다."
            }
        } catch {
            errorMessage = "오류: \(error.localizedDescription)"
        }

        processingRentalId = nil
    }

    func rejectRental(_ rental: AdminRental, reason: String) async {
        guard !reason.isEmpty else {
            errorMessage = "거절 사유를 입력해주세요."
            return
        }

        processingRentalId = rental.id
        errorMessage = nil

        do {
            let response = try await repository.processRental(rentalId: rental.id, action: "reject", rejectionReason: reason)
            if response.success {
                successMessage = "대여가 거절되었습니다."
                await loadRentals()
            } else {
                errorMessage = response.message ?? "거절 처리에 실패했습니다."
            }
        } catch {
            errorMessage = "오류: \(error.localizedDescription)"
        }

        processingRentalId = nil
        rejectionReason = ""
    }

    func prepareRejection(_ rental: AdminRental) {
        selectedRentalForRejection = rental
        rejectionReason = ""
        showRejectionAlert = true
    }

    func filterByStatus(_ status: String) {
        selectedStatus = status
        Task {
            await loadRentals()
        }
    }
}
