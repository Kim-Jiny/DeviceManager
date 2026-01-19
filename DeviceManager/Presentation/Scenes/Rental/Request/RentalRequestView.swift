//
//  RentalRequestView.swift
//  DeviceManager
//

import SwiftUI

struct RentalRequestView: View {
    @StateObject var viewModel: RentalRequestViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.DMColor.main
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Device Info Card
                        deviceInfoCard

                        // Date Selection
                        dateSelectionCard

                        // Duration Info
                        durationCard

                        // Notes
                        notesCard

                        // Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }

                        // Submit Button
                        DMButton(
                            title: "대여 신청",
                            style: .primary,
                            isLoading: viewModel.isLoading,
                            isDisabled: !viewModel.isValid
                        ) {
                            Task {
                                await viewModel.requestRental()
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                            .frame(height: 30)
                    }
                    .padding()
                }
            }
            .navigationTitle("대여 신청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.DMColor.main, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onChange(of: viewModel.isSuccess) { _, success in
                if success {
                    dismiss()
                }
            }
            .alert("대여 신청 완료", isPresented: .constant(viewModel.isSuccess)) {
                Button("확인") {
                    dismiss()
                }
            } message: {
                Text("대여 신청이 완료되었습니다.\n관리자 승인 후 대여가 시작됩니다.")
            }
        }
    }

    // MARK: - Device Info Card

    private var deviceInfoCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "laptopcomputer")
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.device.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(viewModel.device.model)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                if let category = viewModel.device.categoryName {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    // MARK: - Date Selection Card

    private var dateSelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("대여 기간")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                // Start Date
                HStack {
                    Text("시작일")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    DatePicker(
                        "",
                        selection: $viewModel.startDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(.white)
                }

                Divider()
                    .background(Color.white.opacity(0.2))

                // End Date
                HStack {
                    Text("종료일")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    DatePicker(
                        "",
                        selection: $viewModel.endDate,
                        in: viewModel.minEndDate...,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    // MARK: - Duration Card

    private var durationCard: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.blue)

            Text("총 대여 기간")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            Text("\(viewModel.durationDays)일")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("메모 (선택)")
                .font(.headline)
                .foregroundColor(.white)

            TextField("대여 목적이나 특이사항을 입력하세요", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .lineLimit(3...6)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    RentalRequestView(
        viewModel: RentalRequestViewModel(
            device: Device(
                id: 1,
                companyId: 1,
                name: "MacBook Pro 16\"",
                model: "M2 Max",
                serialNumber: "ABC123",
                deviceToken: nil,
                categoryId: 1,
                categoryName: "노트북",
                status: .available,
                purchaseDate: nil,
                warrantyEndDate: nil,
                description: nil,
                imageUrl: nil,
                specs: nil,
                isFavorite: false,
                currentRental: nil,
                createdAt: nil,
                updatedAt: nil
            )
        )
    )
}
