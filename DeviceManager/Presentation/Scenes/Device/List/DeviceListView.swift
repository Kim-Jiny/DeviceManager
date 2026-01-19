//
//  DeviceListView.swift
//  DeviceManager
//

import SwiftUI

struct DeviceListView: View {
    @StateObject var viewModel: DeviceListViewModel
    let onDeviceTap: (Device) -> Void

    var body: some View {
        ZStack {
            Color.DMColor.main
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Search Bar
                searchBar

                // Category Filter
                categoryFilter

                // Device List
                if viewModel.isLoading && viewModel.devices.isEmpty {
                    Spacer()
                    DMLoadingView(message: "디바이스 목록 로딩 중...")
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage, viewModel.devices.isEmpty {
                    Spacer()
                    DMErrorView(message: errorMessage) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    Spacer()
                } else if viewModel.devices.isEmpty {
                    Spacer()
                    DMEmptyStateView(
                        icon: "laptopcomputer.slash",
                        title: "디바이스 없음",
                        message: "등록된 디바이스가 없습니다."
                    )
                    Spacer()
                } else {
                    deviceList
                }
            }
        }
        .navigationTitle("디바이스")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.DMColor.main, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.loadInitialData()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("디바이스 검색", text: $viewModel.searchText)
                .foregroundColor(.white)
                .autocapitalization(.none)
                .submitLabel(.search)
                .onSubmit {
                    viewModel.search()
                }
                .onChange(of: viewModel.searchText) { _, _ in
                    viewModel.search()
                }

            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.categories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: viewModel.selectedCategory?.id == category.id
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Device List
    private var deviceList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.devices) { device in
                    DeviceRow(device: device)
                        .onTapGesture {
                            onDeviceTap(device)
                        }
                        .onAppear {
                            Task {
                                await viewModel.loadMoreIfNeeded(currentDevice: device)
                            }
                        }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                }
            }
            .padding()
        }
    }
}

// MARK: - Category Chip
private struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? Color.DMColor.main : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.white.opacity(0.2))
                .cornerRadius(20)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DeviceListView(
            viewModel: DeviceListViewModel(),
            onDeviceTap: { _ in }
        )
    }
}
