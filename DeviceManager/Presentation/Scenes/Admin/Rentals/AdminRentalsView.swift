//
//  AdminRentalsView.swift
//  DeviceManager
//

import SwiftUI

struct AdminRentalsView: View {
    @StateObject private var viewModel = AdminRentalsViewModel()

    var body: some View {
        ZStack {
            Color.DMColor.main.ignoresSafeArea()

            VStack(spacing: 0) {
                // Status Filter
                statusFilterView

                // Statistics
                if let stats = viewModel.statistics {
                    statisticsView(stats)
                }

                // Content
                if viewModel.isLoading && viewModel.rentals.isEmpty {
                    loadingView
                } else if viewModel.rentals.isEmpty {
                    emptyView
                } else {
                    rentalListView
                }
            }
        }
        .navigationTitle("대여 관리")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadRentals()
        }
        .alert("거절 사유", isPresented: $viewModel.showRejectionAlert) {
            TextField("사유를 입력하세요", text: $viewModel.rejectionReason)
            Button("취소", role: .cancel) {
                viewModel.rejectionReason = ""
            }
            Button("거절", role: .destructive) {
                if let rental = viewModel.selectedRentalForRejection {
                    Task {
                        await viewModel.rejectRental(rental, reason: viewModel.rejectionReason)
                    }
                }
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

    // MARK: - Status Filter

    private var statusFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.statusFilters, id: \.0) { filter in
                    Button {
                        viewModel.filterByStatus(filter.0)
                    } label: {
                        Text(filter.1)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.selectedStatus == filter.0 ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedStatus == filter.0
                                    ? Color.blue
                                    : Color.white.opacity(0.1)
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Statistics

    private func statisticsView(_ stats: AdminRentalStatistics) -> some View {
        HStack(spacing: 12) {
            statisticItem(count: stats.pending, label: "대기", color: .orange)
            statisticItem(count: stats.approved, label: "승인", color: .blue)
            statisticItem(count: stats.active, label: "사용중", color: .green)
            statisticItem(count: stats.returned, label: "반납", color: .gray)
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
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
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            Text("대여 신청이 없습니다")
                .font(.headline)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 8)
            Spacer()
        }
    }

    // MARK: - Rental List

    private var rentalListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.rentals) { rental in
                    AdminRentalRow(
                        rental: rental,
                        isProcessing: viewModel.processingRentalId == rental.id,
                        onApprove: {
                            Task {
                                await viewModel.approveRental(rental)
                            }
                        },
                        onReject: {
                            viewModel.prepareRejection(rental)
                        }
                    )
                }

                // Load More
                if !viewModel.rentals.isEmpty {
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
            await viewModel.loadRentals()
        }
    }
}

// MARK: - Rental Row

struct AdminRentalRow: View {
    let rental: AdminRental
    let isProcessing: Bool
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Device info + Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(rental.device.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(rental.device.model)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Text(rental.statusDisplay)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor)
                    .cornerRadius(12)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // User info
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.white.opacity(0.6))
                VStack(alignment: .leading, spacing: 2) {
                    Text(rental.user.name)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text(rental.user.email)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            // Date info
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.6))
                if let start = rental.requestedStartDate, let end = rental.requestedEndDate {
                    Text("\(formatDate(start)) ~ \(formatDate(end))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // Notes
            if let notes = rental.notes, !notes.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "note.text")
                        .foregroundColor(.white.opacity(0.6))
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // Action buttons (only for PENDING)
            if rental.status == "PENDING" {
                HStack(spacing: 12) {
                    Button {
                        onReject()
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "xmark")
                            }
                            Text("거절")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                    }
                    .disabled(isProcessing)

                    Button {
                        onApprove()
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark")
                            }
                            Text("승인")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .disabled(isProcessing)
                }
                .padding(.top, 4)
            }

            // Rejection reason (if rejected)
            if rental.status == "REJECTED", let reason = rental.rejectionReason {
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("거절 사유: \(reason)")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.9))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch rental.status {
        case "PENDING": return .orange
        case "APPROVED": return .blue
        case "REJECTED": return .red
        case "ACTIVE": return .green
        case "RETURNED": return .gray
        default: return .gray
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "M/d"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}
