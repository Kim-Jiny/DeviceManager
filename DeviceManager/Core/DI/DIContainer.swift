//
//  DIContainer.swift
//  DeviceManager
//

import Foundation

/// 의존성 주입 컨테이너
/// 앱 전체에서 사용되는 의존성들을 관리
@MainActor
final class DIContainer {
    static let shared = DIContainer()

    // MARK: - Core Services
    lazy var networkManager: NetworkManagerProtocol = NetworkManager.shared
    lazy var tokenStorage: TokenStorage = .shared
    lazy var keychainManager: KeychainManager = .shared

    // MARK: - Repositories
    lazy var authRepository: AuthRepositoryProtocol = AuthRepository(
        networkManager: networkManager,
        tokenStorage: tokenStorage
    )

    lazy var deviceRepository: DeviceRepositoryProtocol = DeviceRepository(
        networkManager: networkManager
    )

    lazy var rentalRepository: RentalRepositoryProtocol = RentalRepository(
        networkManager: networkManager
    )

    private init() {}

    // MARK: - Factory Methods for ViewModels

    func makeCompanyNumberViewModel() -> CompanyNumberViewModel {
        CompanyNumberViewModel(authRepository: authRepository)
    }

    func makeLoginViewModel(companyCode: String) -> LoginViewModel {
        LoginViewModel(companyCode: companyCode, authRepository: authRepository)
    }

    func makeSignUpViewModel(companyCode: String) -> SignUpViewModel {
        SignUpViewModel(companyCode: companyCode, authRepository: authRepository)
    }

    func makeDeviceListViewModel() -> DeviceListViewModel {
        DeviceListViewModel(deviceRepository: deviceRepository)
    }

    func makeDeviceDetailViewModel(deviceId: Int) -> DeviceDetailViewModel {
        DeviceDetailViewModel(
            deviceId: deviceId,
            deviceRepository: deviceRepository,
            rentalRepository: rentalRepository
        )
    }

    func makeMyRentalsViewModel() -> MyRentalsViewModel {
        MyRentalsViewModel(rentalRepository: rentalRepository)
    }

    func makeRentalRequestViewModel(device: Device) -> RentalRequestViewModel {
        RentalRequestViewModel(device: device, rentalRepository: rentalRepository)
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(tokenStorage: tokenStorage)
    }

    // MARK: - Reset (for testing or logout)
    func reset() {
        // Recreate repositories with fresh state if needed
    }
}
