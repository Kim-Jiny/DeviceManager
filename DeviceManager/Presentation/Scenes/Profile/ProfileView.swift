//
//  ProfileView.swift
//  DeviceManager
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    let onLogout: () -> Void
    @State private var showLogoutAlert: Bool = false

    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader

                    // User Info Card
                    userInfoCard

                    // Company Info Card
                    companyInfoCard

                    // Logout Button
                    DMButton(
                        title: "로그아웃",
                        style: .outline,
                        action: {
                            showLogoutAlert = true
                        }
                    )
                    .padding(.top, 20)

                    // App Version
                    Text("Device Manager v1.0.0")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 20)

                    Spacer()
                        .frame(height: 30)
                }
                .padding()
            }
        }
        .navigationTitle("프로필")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.DMColor.main, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                onLogout()
            }
        } message: {
            Text("정말 로그아웃 하시겠습니까?")
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.7))

            // Name
            Text(viewModel.userName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Role Badge
            Text(viewModel.userRole)
                .font(.caption)
                .foregroundColor(Color.DMColor.main)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding(.top, 20)
    }

    // MARK: - User Info Card
    private var userInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("계정 정보")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                infoRow(icon: "envelope", title: "이메일", value: viewModel.userEmail)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    // MARK: - Company Info Card
    private var companyInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("회사 정보")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                infoRow(icon: "building.2", title: "회사명", value: viewModel.companyName)

                if let code = viewModel.companyCode {
                    Divider()
                        .background(Color.white.opacity(0.2))

                    infoRow(icon: "number", title: "회사 코드", value: code)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 24)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileView(
            viewModel: ProfileViewModel(),
            onLogout: {}
        )
    }
}
