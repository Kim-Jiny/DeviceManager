//
//  ProfileViewModel.swift
//  DeviceManager
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var user: User?
    @Published private(set) var companyCode: String?

    // MARK: - Private Properties

    private let tokenStorage: TokenStorageProtocol

    // MARK: - Computed Properties

    var userName: String {
        user?.name ?? "사용자"
    }

    var userEmail: String {
        user?.email ?? "-"
    }

    var userRole: String {
        user?.role.displayName ?? "-"
    }

    var companyName: String {
        user?.company?.name ?? "-"
    }

    var userInitial: String {
        String(userName.prefix(1)).uppercased()
    }

    var isAdmin: Bool {
        user?.role == .companyAdmin || user?.role == .systemAdmin
    }

    // MARK: - Initialization

    init(tokenStorage: TokenStorageProtocol = TokenStorage.shared) {
        self.tokenStorage = tokenStorage
        loadUserInfo()
    }

    // MARK: - Public Methods

    func loadUserInfo() {
        user = tokenStorage.getUser()
        companyCode = tokenStorage.getCompanyCode()
    }

    func refresh() {
        loadUserInfo()
    }
}
