//
//  DeviceListViewModel.swift
//  DeviceManager
//

import Foundation
import Combine

@MainActor
final class DeviceListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var state = PaginatedState<Device>()
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var searchText: String = ""

    // MARK: - Private Properties

    private let limit: Int = 12
    private let deviceRepository: DeviceRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    // MARK: - Computed Properties

    var devices: [Device] { state.items }
    var isLoading: Bool { state.isLoading }
    var isLoadingMore: Bool { state.isLoadingMore }
    var errorMessage: String? { state.error }
    var hasMorePages: Bool { state.hasMorePages }
    var isEmpty: Bool { state.isEmpty }

    // MARK: - Initialization

    init(deviceRepository: DeviceRepositoryProtocol = DeviceRepository()) {
        self.deviceRepository = deviceRepository
    }

    // MARK: - Public Methods

    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadCategories() }
            group.addTask { await self.loadDevices(reset: true) }
        }
    }

    func loadCategories() async {
        do {
            let fetchedCategories = try await deviceRepository.getCategories()
            categories = [Category.all] + fetchedCategories
            if selectedCategory == nil {
                selectedCategory = Category.all
            }
        } catch {
            categories = [Category.all]
            selectedCategory = Category.all
        }
    }

    func loadDevices(reset: Bool = false) async {
        state.startLoading(reset: reset)

        do {
            let categoryId = selectedCategory?.id == -1 ? nil : selectedCategory?.id
            let search = searchText.trimmingCharacters(in: .whitespaces)

            let response = try await deviceRepository.getDevices(
                page: state.currentPage,
                limit: limit,
                search: search.isEmpty ? nil : search,
                status: nil,
                categoryId: categoryId
            )

            state.finishLoading(
                newItems: response.devices,
                totalPages: response.pagination.totalPages,
                reset: reset
            )
        } catch let error as NetworkError {
            state.setError(error.localizedDescription)
        } catch {
            state.setError("디바이스 목록을 불러오는데 실패했습니다.")
        }
    }

    func loadMoreIfNeeded(currentDevice: Device) async {
        guard let lastDevice = devices.last,
              lastDevice.id == currentDevice.id,
              hasMorePages,
              !isLoadingMore else {
            return
        }

        await loadDevices(reset: false)
    }

    func refresh() async {
        await loadDevices(reset: true)
    }

    func selectCategory(_ category: Category) {
        guard selectedCategory?.id != category.id else { return }
        selectedCategory = category
        Task {
            await loadDevices(reset: true)
        }
    }

    func search() {
        // 디바운싱: 이전 검색 작업 취소
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초 디바운스
            guard !Task.isCancelled else { return }
            await loadDevices(reset: true)
        }
    }

    func clearSearch() {
        searchText = ""
        Task {
            await loadDevices(reset: true)
        }
    }
}
