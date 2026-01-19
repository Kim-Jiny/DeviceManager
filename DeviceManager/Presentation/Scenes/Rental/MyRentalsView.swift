//
//  MyRentalsView.swift
//  DeviceManager
//

import SwiftUI

struct MyRentalsView: View {
    @StateObject var viewModel: MyRentalsViewModel

    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Statistics Header
                if let stats = viewModel.statistics {
                    statisticsHeader(stats)
                }

                // Rental List
                if viewModel.isLoading && viewModel.rentals.isEmpty {
                    Spacer()
                    DMLoadingView(message: "대여 목록 로딩 중...")
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage, viewModel.rentals.isEmpty {
                    Spacer()
                    DMErrorView(message: errorMessage) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    Spacer()
                } else if viewModel.rentals.isEmpty {
                    Spacer()
                    DMEmptyStateView(
                        icon: "list.clipboard",
                        title: "대여 내역 없음",
                        message: "아직 대여 내역이 없습니다."
                    )
                    Spacer()
                } else {
                    rentalList
                }
            }
        }
        .navigationTitle("내 대여")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.DMColor.main, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.loadRentals()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Statistics Header
    private func statisticsHeader(_ stats: RentalStatistics) -> some View {
        HStack(spacing: 16) {
            StatCard(title: "전체", value: "\(stats.totalRentals)", color: .blue)
            StatCard(title: "대여중", value: "\(stats.activeRentals)", color: .green)
            StatCard(title: "연체", value: "\(stats.overdueCount)", color: .red)
        }
        .padding()
    }

    // MARK: - Rental List
    private var rentalList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.rentals) { rental in
                    RentalRow(rental: rental)
                }
            }
            .padding()
        }
    }
}

// MARK: - Stat Card
private struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Rental Row
private struct RentalRow: View {
    let rental: Rental

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Device Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(rental.device.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    if let model = rental.device.model {
                        Text(model)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                // Status Badge
                Text(rental.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor)
                    .cornerRadius(8)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // Date Info
            HStack {
                Label(rental.requestedStartDate, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                Text("~")
                    .foregroundColor(.white.opacity(0.5))

                Text(rental.requestedEndDate)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                if rental.isOverdue == true {
                    Label("연체", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch rental.status {
        case .pending:
            return .orange
        case .approved:
            return .blue
        case .active:
            return .green
        case .returned:
            return .gray
        case .rejected:
            return .red
        case .cancelled:
            return .gray
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MyRentalsView(viewModel: MyRentalsViewModel())
    }
}
