//
//  AdminUsersView.swift
//  DeviceManager
//

import SwiftUI

struct AdminUsersView: View {
    @StateObject private var viewModel = AdminUsersViewModel()

    var body: some View {
        ZStack {
            Color.DMColor.main.ignoresSafeArea()

            VStack(spacing: 0) {
                // Search Bar
                searchBar

                // Role Filter
                roleFilterView

                // Statistics
                if let stats = viewModel.statistics {
                    statisticsView(stats)
                }

                // Content
                if viewModel.isLoading && viewModel.users.isEmpty {
                    loadingView
                } else if viewModel.users.isEmpty {
                    emptyView
                } else {
                    userListView
                }
            }
        }
        .navigationTitle("사용자 관리")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadUsers()
        }
        .confirmationDialog("역할 변경", isPresented: $viewModel.showRoleChangeAlert, titleVisibility: .visible) {
            if let user = viewModel.selectedUserForRoleChange {
                if user.role != "USER" {
                    Button("일반 사용자로 변경") {
                        Task {
                            await viewModel.changeUserRole(user, to: "USER")
                        }
                    }
                }
                if user.role != "COMPANY_MANAGER" {
                    Button("매니저로 변경") {
                        Task {
                            await viewModel.changeUserRole(user, to: "COMPANY_MANAGER")
                        }
                    }
                }
                Button("취소", role: .cancel) {}
            }
        } message: {
            if let user = viewModel.selectedUserForRoleChange {
                Text("\(user.name)님의 역할을 변경합니다")
            }
        }
        .alert("성공", isPresented: .init(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.successMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            if let message = viewModel.successMessage {
                Text(message)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.5))
            TextField("이름 또는 이메일 검색", text: $viewModel.searchText)
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onSubmit {
                    viewModel.search()
                }
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    viewModel.search()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }

    // MARK: - Role Filter

    private var roleFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.roleFilters, id: \.0) { filter in
                    Button {
                        viewModel.filterByRole(filter.0)
                    } label: {
                        Text(filter.1)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.selectedRoleFilter == filter.0 ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedRoleFilter == filter.0
                                    ? Color.blue
                                    : Color.white.opacity(0.1)
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Statistics

    private func statisticsView(_ stats: UserStatistics) -> some View {
        HStack(spacing: 12) {
            statisticItem(count: stats.user, label: "일반", color: .gray)
            statisticItem(count: stats.companyManager, label: "매니저", color: .blue)
            statisticItem(count: stats.companyAdmin, label: "관리자", color: .purple)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private func statisticItem(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(.white)
            Text("불러오는 중...")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 8)
            Spacer()
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack {
            Spacer()
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            Text("사용자가 없습니다")
                .font(.headline)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 8)
            Spacer()
        }
    }

    // MARK: - User List

    private var userListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.users) { user in
                    AdminUserRow(
                        user: user,
                        isProcessing: viewModel.processingUserId == user.id,
                        onRoleChange: {
                            viewModel.prepareRoleChange(user)
                        }
                    )
                }

                if !viewModel.users.isEmpty {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadUsers()
        }
    }
}

// MARK: - User Row

struct AdminUserRow: View {
    let user: CompanyUser
    let isProcessing: Bool
    let onRoleChange: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(roleColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(user.name.prefix(1))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(roleColor)
                }

            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(user.roleDisplay)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(roleColor)
                        .cornerRadius(4)
                }

                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                HStack(spacing: 12) {
                    Label("\(user.activeRentalsCount)", systemImage: "laptopcomputer")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Label("\(user.totalRentalsCount)건 대여", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            // Role Change Button (only for non-admin users)
            if user.canChangeRole {
                Button {
                    onRoleChange()
                } label: {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "person.badge.key")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .disabled(isProcessing)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    private var roleColor: Color {
        switch user.role {
        case "COMPANY_ADMIN": return .purple
        case "COMPANY_MANAGER": return .blue
        default: return .gray
        }
    }
}
