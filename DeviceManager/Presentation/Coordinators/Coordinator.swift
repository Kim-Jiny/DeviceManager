//
//  Coordinator.swift
//  DeviceManager
//

import SwiftUI

// MARK: - Coordinator Protocol
@MainActor
protocol Coordinator: ObservableObject {
    associatedtype ContentView: View
    var navigationPath: NavigationPath { get set }
    func start() -> ContentView
}

// MARK: - Auth Flow Destinations
enum AuthDestination: Hashable {
    case login(companyCode: String)
    case signUp(companyCode: String)
}

// MARK: - Main Flow Destinations
enum MainDestination: Hashable {
    case deviceDetail(deviceId: Int)
    case rentalRequest(device: Device)
    case myRentals
    case profile
}

// Make Device Hashable for navigation
extension Device: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
}
