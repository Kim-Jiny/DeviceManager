//
//  AdminUsersViewModel.swift
//  DeviceManager
//

import Foundation

@MainActor
final class AdminUsersViewModel: ObservableObject {
    @Published var users: [CompanyUser] = []
    @Published var statistics: UserStatistics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedRoleFilter: String = ""
    @Published var showRoleChangeAlert = false
    @Published var selectedUserForRoleChange: CompanyUser?
    @Published var processingUserId: Int?
    @Published var successMessage: String?

    private let repository: AdminRepository
    private var currentPage = 1
    private var totalPages = 1

    let roleFilters = [
        ("", "전체"),
        ("USER", "일반 사용자"),
        ("COMPANY_MANAGER", "매니저")
    ]

    init(repository: AdminRepository = AdminRepository()) {
        self.repository = repository
    }

    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            let response = try await repository.getCompanyUsers(
                page: currentPage,
                limit: 20,
                search: searchText.isEmpty ? nil : searchText,
                role: selectedRoleFilter.isEmpty ? nil : selectedRoleFilter
            )
            if response.success, let data = response.data {
                users = data.users
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
            let response = try await repository.getCompanyUsers(
                page: currentPage,
                limit: 20,
                search: searchText.isEmpty ? nil : searchText,
                role: selectedRoleFilter.isEmpty ? nil : selectedRoleFilter
            )
            if response.success, let data = response.data {
                users.append(contentsOf: data.users)
            }
        } catch {
            currentPage -= 1
        }
    }

    func changeUserRole(_ user: CompanyUser, to newRole: String) async {
        processingUserId = user.id
        errorMessage = nil

        do {
            let response = try await repository.updateUserRole(userId: user.id, newRole: newRole)
            if response.success {
                successMessage = "\(user.name)님의 역할이 변경되었습니다."
                await loadUsers()
            } else {
                errorMessage = response.message ?? "역할 변경에 실패했습니다."
            }
        } catch {
            errorMessage = "오류: \(error.localizedDescription)"
        }

        processingUserId = nil
    }

    func prepareRoleChange(_ user: CompanyUser) {
        selectedUserForRoleChange = user
        showRoleChangeAlert = true
    }

    func filterByRole(_ role: String) {
        selectedRoleFilter = role
        Task {
            await loadUsers()
        }
    }

    func search() {
        Task {
            await loadUsers()
        }
    }
}
