//
//  Category.swift
//  DeviceManager
//

import Foundation

// MARK: - Category Model
struct Category: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let createdAt: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Category List Response
struct CategoryListResponse: Decodable {
    let categories: [Category]
}

// MARK: - All Categories Option
extension Category {
    static let all = Category(
        id: -1,
        name: "전체",
        description: "모든 카테고리",
        createdAt: nil
    )
}
