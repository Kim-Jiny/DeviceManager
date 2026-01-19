//
//  AppCoordinator.swift
//  DeviceManager
//

import SwiftUI

// MARK: - App State
enum AppState {
    case loading
    case auth
    case main
}

// MARK: - App Coordinator
@MainActor
final class AppCoordinator: ObservableObject {
    @Published var appState: AppState = .loading
    @Published var authCoordinator: AuthCoordinator?
    @Published var mainCoordinator: MainCoordinator?

    private let tokenStorage: TokenStorage

    init(tokenStorage: TokenStorage = .shared) {
        self.tokenStorage = tokenStorage
    }

    func checkAuthState() {
        if tokenStorage.isLoggedIn() {
            showMain()
        } else if tokenStorage.getCompanyCode() != nil {
            // Has company code but not logged in
            showAuth()
        } else {
            showAuth()
        }
    }

    func showAuth() {
        authCoordinator = AuthCoordinator(
            onLoginSuccess: { [weak self] in
                self?.showMain()
            }
        )
        mainCoordinator = nil
        appState = .auth
    }

    func showMain() {
        mainCoordinator = MainCoordinator(
            onLogout: { [weak self] in
                self?.tokenStorage.clearAll()
                self?.showAuth()
            }
        )
        authCoordinator = nil
        appState = .main
    }

    func logout() {
        tokenStorage.clearAll()
        showAuth()
    }
}

// MARK: - Root View
struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        Group {
            switch coordinator.appState {
            case .loading:
                LoadingView()
                    .onAppear {
                        coordinator.checkAuthState()
                    }
            case .auth:
                if let authCoordinator = coordinator.authCoordinator {
                    authCoordinator.start()
                }
            case .main:
                if let mainCoordinator = coordinator.mainCoordinator {
                    mainCoordinator.start()
                }
            }
        }
        .environmentObject(coordinator)
    }
}

// MARK: - Loading View
private struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                Text("로딩 중...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
    }
}
