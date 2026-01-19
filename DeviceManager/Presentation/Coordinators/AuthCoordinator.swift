//
//  AuthCoordinator.swift
//  DeviceManager
//

import SwiftUI

@MainActor
final class AuthCoordinator: ObservableObject, Coordinator {
    @Published var navigationPath = NavigationPath()

    private let onLoginSuccess: () -> Void
    private let tokenStorage: TokenStorage

    init(
        tokenStorage: TokenStorage = .shared,
        onLoginSuccess: @escaping () -> Void
    ) {
        self.tokenStorage = tokenStorage
        self.onLoginSuccess = onLoginSuccess
    }

    func start() -> some View {
        AuthCoordinatorView(coordinator: self)
    }

    func navigateToLogin(companyCode: String) {
        tokenStorage.saveCompanyCode(companyCode)
        navigationPath.append(AuthDestination.login(companyCode: companyCode))
    }

    func navigateToSignUp(companyCode: String) {
        navigationPath.append(AuthDestination.signUp(companyCode: companyCode))
    }

    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func loginSuccess() {
        onLoginSuccess()
    }
}

// MARK: - Auth Coordinator View
struct AuthCoordinatorView: View {
    @ObservedObject var coordinator: AuthCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            CompanyNumberView(
                viewModel: CompanyNumberViewModel(),
                onValidCompany: { companyCode in
                    coordinator.navigateToLogin(companyCode: companyCode)
                }
            )
            .navigationDestination(for: AuthDestination.self) { destination in
                switch destination {
                case .login(let companyCode):
                    LoginView(
                        viewModel: LoginViewModel(companyCode: companyCode),
                        onLoginSuccess: {
                            coordinator.loginSuccess()
                        },
                        onSignUpTap: {
                            coordinator.navigateToSignUp(companyCode: companyCode)
                        },
                        onBack: {
                            coordinator.goBack()
                        }
                    )
                case .signUp(let companyCode):
                    SignUpView(
                        viewModel: SignUpViewModel(companyCode: companyCode),
                        onSignUpSuccess: {
                            coordinator.goBack()
                        },
                        onBack: {
                            coordinator.goBack()
                        }
                    )
                }
            }
        }
    }
}
