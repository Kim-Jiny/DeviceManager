//
//  RentalRequestViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class RentalRequestViewModel: ObservableObject {
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var notes: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSuccess: Bool = false

    let device: Device
    private let rentalRepository: RentalRepositoryProtocol

    init(device: Device, rentalRepository: RentalRepositoryProtocol = RentalRepository()) {
        self.device = device
        self.rentalRepository = rentalRepository
    }

    var isInputValid: Bool {
        endDate > startDate
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    func requestRental() async {
        guard isInputValid else {
            errorMessage = "종료일은 시작일보다 이후여야 합니다."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await rentalRepository.requestRental(
                deviceId: device.id,
                startDate: dateFormatter.string(from: startDate),
                endDate: dateFormatter.string(from: endDate),
                notes: notes.isEmpty ? nil : notes
            )
            isSuccess = true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "대여 신청 중 오류가 발생했습니다."
        }

        isLoading = false
    }
}
