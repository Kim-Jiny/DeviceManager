//
//  RentalRequestView.swift
//  DeviceManager
//

import SwiftUI

struct RentalRequestView: View {
    @StateObject var viewModel: RentalRequestViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Device Info
                    deviceInfoCard

                    // Date Selection
                    dateSelectionCard

                    // Notes
                    notesCard

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Submit Button
                    DMButton(
                        title: "대여 신청",
                        style: .primary,
                        action: {
                            Task {
                                await viewModel.requestRental()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isInputValid
                    )
                    .padding(.top, 10)

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
        .onChange(of: viewModel.isSuccess) { _, isSuccess in
            if isSuccess {
                dismiss()
            }
        }
    }

    // MARK: - Device Info Card
    private var deviceInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("대여 장비")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                Image(systemName: "laptopcomputer.and.iphone")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.device.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)

                    Text(viewModel.device.model)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
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
                DatePicker(
                    "시작일",
                    selection: $viewModel.startDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .colorScheme(.dark)

                Divider()
                    .background(Color.white.opacity(0.2))

                DatePicker(
                    "종료일",
                    selection: $viewModel.endDate,
                    in: viewModel.startDate...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .colorScheme(.dark)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }

    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("비고 (선택)")
                .font(.headline)
                .foregroundColor(.white)

            TextField("대여 목적이나 요청사항을 입력하세요", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .lineLimit(3...6)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        RentalRequestView(
            viewModel: RentalRequestViewModel(
                device: Device(
                    id: 1,
                    companyId: 1,
                    name: "MacBook Pro",
                    model: "14인치 M3",
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
                    pendingRental: nil,
                    createdAt: nil,
                    updatedAt: nil
                )
            )
        )
    }
}
