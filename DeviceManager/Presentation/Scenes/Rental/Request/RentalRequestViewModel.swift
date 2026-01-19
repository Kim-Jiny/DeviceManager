//
//  RentalRequestViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class RentalRequestViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var startDate: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var notes: String = ""
    @Published private(set) var formState = FormState()

    // MARK: - Properties

    let device: Device
    private let rentalRepository: RentalRepositoryProtocol

    // MARK: - Computed Properties

    var isLoading: Bool { formState.isSubmitting }
    var errorMessage: String? { formState.errorMessage }
    var isSuccess: Bool { formState.isSuccess }

    var isValid: Bool {
        endDate >= startDate
    }

    var durationDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }

    var minEndDate: Date {
        startDate
    }

    // MARK: - Initialization

    init(device: Device, rentalRepository: RentalRepositoryProtocol = RentalRepository()) {
        self.device = device
        self.rentalRepository = rentalRepository
    }

    // MARK: - Public Methods

    func requestRental() async {
        guard isValid else {
            formState.failure("종료일은 시작일 이후여야 합니다.")
            return
        }

        formState.startSubmitting()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        do {
            _ = try await rentalRepository.requestRental(
                deviceId: device.id,
                startDate: dateFormatter.string(from: startDate),
                endDate: dateFormatter.string(from: endDate),
                notes: notes.isEmpty ? nil : notes
            )
            formState.success()
        } catch let error as NetworkError {
            formState.failure(error.localizedDescription)
        } catch {
            formState.failure("대여 신청 중 오류가 발생했습니다.")
        }
    }

    func reset() {
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        notes = ""
        formState.reset()
    }
}
