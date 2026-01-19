//
//  DeviceDetailViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class DeviceDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var state: ViewState<Device> = .idle
    @Published private(set) var rentalState = FormState()

    // MARK: - Properties

    let deviceId: Int
    private let deviceRepository: DeviceRepositoryProtocol
    private let rentalRepository: RentalRepositoryProtocol

    // MARK: - Computed Properties

    var device: Device? { state.data }
    var isLoading: Bool { state.isLoading }
    var errorMessage: String? { state.errorMessage }

    var canRent: Bool {
        device?.status == .available
    }

    var statusDescription: String {
        guard let device = device else { return "" }
        switch device.status {
        case .available:
            return "현재 대여 가능합니다."
        case .rented:
            if let rental = device.currentRental {
                return "\(rental.userName ?? "사용자")님이 대여 중입니다."
            }
            return "현재 대여 중입니다."
        case .maintenance:
            return "점검 중입니다."
        case .retired:
            return "폐기된 장비입니다."
        }
    }

    // MARK: - Initialization

    init(
        deviceId: Int,
        deviceRepository: DeviceRepositoryProtocol = DeviceRepository(),
        rentalRepository: RentalRepositoryProtocol = RentalRepository()
    ) {
        self.deviceId = deviceId
        self.deviceRepository = deviceRepository
        self.rentalRepository = rentalRepository
    }

    // MARK: - Public Methods

    func loadDevice() async {
        state = .loading

        do {
            let device = try await deviceRepository.getDeviceDetail(id: deviceId)
            state = .loaded(device)
        } catch let error as NetworkError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error("디바이스 정보를 불러오는데 실패했습니다.")
        }
    }

    func refresh() async {
        await loadDevice()
    }
}
