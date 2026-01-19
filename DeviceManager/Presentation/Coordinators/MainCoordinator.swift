//
//  MainCoordinator.swift
//  DeviceManager
//

import SwiftUI

@MainActor
final class MainCoordinator: ObservableObject, Coordinator {
    @Published var navigationPath = NavigationPath()
    @Published var selectedTab: MainTab = .devices

    private let onLogout: () -> Void

    init(onLogout: @escaping () -> Void) {
        self.onLogout = onLogout
    }

    func start() -> some View {
        MainCoordinatorView(coordinator: self)
    }

    func navigateToDeviceDetail(deviceId: Int) {
        navigationPath.append(MainDestination.deviceDetail(deviceId: deviceId))
    }

    func navigateToRentalRequest(device: Device) {
        navigationPath.append(MainDestination.rentalRequest(device: device))
    }

    func navigateToMyRentals() {
        navigationPath.append(MainDestination.myRentals)
    }

    func navigateToProfile() {
        navigationPath.append(MainDestination.profile)
    }

    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func logout() {
        onLogout()
    }
}

// MARK: - Main Tab
enum MainTab: String, CaseIterable {
    case devices = "devices"
    case rentals = "rentals"
    case admin = "admin"
    case profile = "profile"

    var title: String {
        switch self {
        case .devices:
            return "디바이스"
        case .rentals:
            return "내 대여"
        case .admin:
            return "관리"
        case .profile:
            return "프로필"
        }
    }

    var icon: String {
        switch self {
        case .devices:
            return "laptopcomputer.and.iphone"
        case .rentals:
            return "list.clipboard"
        case .admin:
            return "gearshape.2"
        case .profile:
            return "person.circle"
        }
    }
}

// MARK: - Main Coordinator View
struct MainCoordinatorView: View {
    @ObservedObject var coordinator: MainCoordinator
    private let tokenStorage = TokenStorage.shared

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.navigationPath) {
                DeviceListView(
                    viewModel: DeviceListViewModel(),
                    onDeviceTap: { device in
                        coordinator.navigateToDeviceDetail(deviceId: device.id)
                    }
                )
                .navigationDestination(for: MainDestination.self) { destination in
                    destinationView(for: destination)
                }
            }
            .tabItem {
                Label(MainTab.devices.title, systemImage: MainTab.devices.icon)
            }
            .tag(MainTab.devices)

            NavigationStack {
                MyRentalsView(viewModel: MyRentalsViewModel())
            }
            .tabItem {
                Label(MainTab.rentals.title, systemImage: MainTab.rentals.icon)
            }
            .tag(MainTab.rentals)

            // Admin tab (only for managers and admins)
            if tokenStorage.isManager {
                AdminView(userRole: tokenStorage.currentUserRole)
                    .tabItem {
                        Label(MainTab.admin.title, systemImage: MainTab.admin.icon)
                    }
                    .tag(MainTab.admin)
            }

            NavigationStack {
                ProfileView(
                    viewModel: ProfileViewModel(),
                    onLogout: {
                        coordinator.logout()
                    }
                )
            }
            .tabItem {
                Label(MainTab.profile.title, systemImage: MainTab.profile.icon)
            }
            .tag(MainTab.profile)
        }
        .tint(Color.DMColor.white)
    }

    @ViewBuilder
    private func destinationView(for destination: MainDestination) -> some View {
        switch destination {
        case .deviceDetail(let deviceId):
            DeviceDetailView(viewModel: DeviceDetailViewModel(deviceId: deviceId))
        case .rentalRequest(let device):
            RentalRequestView(viewModel: RentalRequestViewModel(device: device))
        case .myRentals:
            MyRentalsView(viewModel: MyRentalsViewModel())
        case .profile:
            ProfileView(viewModel: ProfileViewModel(), onLogout: { coordinator.logout() })
        }
    }
}
