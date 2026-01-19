//
//  ViewState.swift
//  DeviceManager
//

import Foundation

/// 공통 뷰 상태 관리를 위한 enum
enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }

    var hasData: Bool {
        data != nil
    }
}

/// 리스트 데이터를 위한 페이지네이션 상태
struct PaginatedState<T: Equatable>: Equatable {
    var items: [T] = []
    var currentPage: Int = 1
    var totalPages: Int = 1
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var error: String?

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    var isEmpty: Bool {
        items.isEmpty && !isLoading
    }

    mutating func reset() {
        items = []
        currentPage = 1
        totalPages = 1
        isLoading = false
        isLoadingMore = false
        error = nil
    }

    mutating func startLoading(reset: Bool) {
        if reset {
            self.reset()
            isLoading = true
        } else {
            isLoadingMore = true
        }
        error = nil
    }

    mutating func finishLoading(newItems: [T], totalPages: Int, reset: Bool) {
        if reset {
            items = newItems
        } else {
            items.append(contentsOf: newItems)
        }
        self.totalPages = totalPages
        currentPage += 1
        isLoading = false
        isLoadingMore = false
    }

    mutating func setError(_ message: String) {
        error = message
        isLoading = false
        isLoadingMore = false
    }
}

/// 폼 상태 관리
struct FormState: Equatable {
    var isSubmitting: Bool = false
    var isSuccess: Bool = false
    var errorMessage: String?

    mutating func startSubmitting() {
        isSubmitting = true
        errorMessage = nil
    }

    mutating func success() {
        isSubmitting = false
        isSuccess = true
        errorMessage = nil
    }

    mutating func failure(_ message: String) {
        isSubmitting = false
        isSuccess = false
        errorMessage = message
    }

    mutating func reset() {
        isSubmitting = false
        isSuccess = false
        errorMessage = nil
    }
}
