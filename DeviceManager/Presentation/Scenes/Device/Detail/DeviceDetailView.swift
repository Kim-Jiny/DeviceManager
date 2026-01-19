//
//  DeviceDetailView.swift
//  DeviceManager
//

import SwiftUI

struct DeviceDetailView: View {
    @StateObject var viewModel: DeviceDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            if viewModel.isLoading {
                DMLoadingView(message: "디바이스 정보 로딩 중...")
            } else if let errorMessage = viewModel.errorMessage {
                DMErrorView(message: errorMessage) {
                    Task {
                        await viewModel.loadDevice()
                    }
                }
            } else if let device = viewModel.device {
                ScrollView {
                    VStack(spacing: 20) {
                        // Device Header
                        deviceHeader(device)

                        // Status Card
                        statusCard(device)

                        // Specs Card
                        if device.specs != nil {
                            specsCard(device)
                        }

                        // Current Rental Info
                        if let rental = device.currentRental {
                            rentalCard(rental)
                        }

                        // Action Button
                        if device.status == .available {
                            DMButton(title: "대여 신청", style: .primary) {
                                // Handle rental request
                            }
                            .padding(.horizontal)
                        }

                        Spacer()
                            .frame(height: 30)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("디바이스 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.DMColor.main, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.loadDevice()
        }
    }

    // MARK: - Device Header
    private func deviceHeader(_ device: Device) -> some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: "laptopcomputer.and.iphone")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)

            // Name
            Text(device.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(device.model)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
    }

    // MARK: - Status Card
    private func statusCard(_ device: Device) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("상태")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Label(device.status.displayName, systemImage: "circle.fill")
                    .font(.body)
                    .foregroundColor(statusColor(device.status))

                Spacer()

                if let categoryName = device.categoryName {
                    Text(categoryName)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }

            if let serialNumber = device.serialNumber.isEmpty ? nil : device.serialNumber {
                Divider()
                    .background(Color.white.opacity(0.2))

                HStack {
                    Text("시리얼 번호")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text(serialNumber)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    private func statusColor(_ status: DeviceStatus) -> Color {
        switch status {
        case .available:
            return .green
        case .rented:
            return .orange
        case .maintenance:
            return .yellow
        case .retired:
            return .gray
        }
    }

    // MARK: - Specs Card
    private func specsCard(_ device: Device) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사양")
                .font(.headline)
                .foregroundColor(.white)

            if let specs = device.specs {
                VStack(spacing: 8) {
                    if let cpu = specs.cpu {
                        specRow(title: "CPU", value: cpu)
                    }
                    if let ram = specs.ram {
                        specRow(title: "RAM", value: ram)
                    }
                    if let storage = specs.storage {
                        specRow(title: "저장공간", value: storage)
                    }
                    if let display = specs.display {
                        specRow(title: "디스플레이", value: display)
                    }
                    if let os = specs.os {
                        specRow(title: "OS", value: os)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    private func specRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.white)
        }
    }

    // MARK: - Rental Card
    private func rentalCard(_ rental: CurrentRental) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("현재 대여 정보")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Image(systemName: "person.circle")
                    .foregroundColor(.white.opacity(0.7))

                Text(rental.userName ?? "알 수 없음")
                    .font(.body)
                    .foregroundColor(.white)

                Spacer()

                if let endDate = rental.endDate {
                    Text("반납 예정: \(endDate)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(16)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DeviceDetailView(viewModel: DeviceDetailViewModel(deviceId: 1))
    }
}
