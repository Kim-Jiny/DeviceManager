//
//  AdminView.swift
//  DeviceManager
//

import SwiftUI

struct AdminView: View {
    let userRole: UserRole

    var body: some View {
        NavigationStack {
            ZStack {
                Color.DMColor.main.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        VStack(spacing: 4) {
                            Text("관리")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(userRole.isAdmin ? "관리자" : "매니저")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)

                        // Menu Items
                        VStack(spacing: 12) {
                            // Rental Management
                            NavigationLink {
                                AdminRentalsView()
                            } label: {
                                AdminMenuItem(
                                    icon: "list.clipboard",
                                    title: "대여 관리",
                                    description: "대여 신청 승인/거절, 현황 확인",
                                    color: .orange
                                )
                            }

                            // Device Status (Managers can change status)
                            NavigationLink {
                                AdminDeviceStatusView()
                            } label: {
                                AdminMenuItem(
                                    icon: "wrench.and.screwdriver",
                                    title: "디바이스 상태 관리",
                                    description: "디바이스 상태 변경 (점검, 폐기 등)",
                                    color: .blue
                                )
                            }

                            // User Management (Admin only)
                            if userRole.isAdmin {
                                NavigationLink {
                                    AdminUsersView()
                                } label: {
                                    AdminMenuItem(
                                        icon: "person.2",
                                        title: "사용자 관리",
                                        description: "사용자 역할 변경 (매니저 지정)",
                                        color: .purple
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Menu Item

struct AdminMenuItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Device Status View (Simple placeholder)

struct AdminDeviceStatusView: View {
    @StateObject private var viewModel = DeviceListViewModel()
    @State private var showStatusChangeSheet = false
    @State private var selectedDevice: Device?
    @State private var selectedStatus: DeviceStatus = .available
    @State private var statusNote = ""
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let adminRepository = AdminRepository()

    var body: some View {
        ZStack {
            Color.DMColor.main.ignoresSafeArea()

            if viewModel.isLoading && viewModel.devices.isEmpty {
                ProgressView()
                    .tint(.white)
            } else if viewModel.devices.isEmpty {
                VStack {
                    Image(systemName: "laptopcomputer.and.iphone")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.3))
                    Text("디바이스가 없습니다")
                        .foregroundColor(.white.opacity(0.6))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.devices) { device in
                            DeviceStatusRow(device: device) {
                                selectedDevice = device
                                selectedStatus = device.status
                                statusNote = ""
                                showStatusChangeSheet = true
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.loadDevices()
                }
            }
        }
        .navigationTitle("디바이스 상태 관리")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDevices()
        }
        .sheet(isPresented: $showStatusChangeSheet) {
            statusChangeSheet
        }
        .alert("오류", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            if let message = errorMessage {
                Text(message)
            }
        }
        .alert("성공", isPresented: .init(
            get: { successMessage != nil },
            set: { if !$0 { successMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            if let message = successMessage {
                Text(message)
            }
        }
    }

    private var statusChangeSheet: some View {
        NavigationStack {
            ZStack {
                Color.DMColor.main.ignoresSafeArea()

                VStack(spacing: 20) {
                    if let device = selectedDevice {
                        Text(device.name)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("현재 상태: \(device.status.displayName)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))

                        Divider()
                            .background(Color.white.opacity(0.3))

                        Text("변경할 상태 선택")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))

                        VStack(spacing: 10) {
                            ForEach([DeviceStatus.available, .maintenance, .retired], id: \.self) { status in
                                Button {
                                    selectedStatus = status
                                } label: {
                                    HStack {
                                        Text(status.displayName)
                                            .foregroundColor(.white)
                                        Spacer()
                                        if selectedStatus == status {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        selectedStatus == status
                                            ? Color.white.opacity(0.2)
                                            : Color.white.opacity(0.1)
                                    )
                                    .cornerRadius(10)
                                }
                            }
                        }

                        TextField("변경 사유 (선택)", text: $statusNote)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top)

                        Spacer()

                        Button {
                            Task {
                                await changeStatus()
                            }
                        } label: {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("상태 변경")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(device.status == selectedStatus ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(device.status == selectedStatus || isProcessing)
                    }
                }
                .padding()
            }
            .navigationTitle("상태 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        showStatusChangeSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func changeStatus() async {
        guard let device = selectedDevice else { return }

        isProcessing = true
        do {
            let response = try await adminRepository.updateDeviceStatus(
                deviceId: device.id,
                status: selectedStatus.rawValue,
                note: statusNote.isEmpty ? nil : statusNote
            )

            if response.success {
                successMessage = "상태가 변경되었습니다."
                showStatusChangeSheet = false
                await viewModel.loadDevices()
            } else {
                errorMessage = response.message ?? "상태 변경에 실패했습니다."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isProcessing = false
    }
}

struct DeviceStatusRow: View {
    let device: Device
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "laptopcomputer")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(device.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(device.model)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Text(device.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor)
                    .cornerRadius(12)

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }

    private var statusColor: Color {
        switch device.status {
        case .available: return .green
        case .rented: return .orange
        case .maintenance: return .yellow
        case .retired: return .gray
        }
    }
}
