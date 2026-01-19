//
//  DeviceRow.swift
//  DeviceManager
//

import SwiftUI

struct DeviceRow: View {
    let device: Device

    var body: some View {
        HStack(spacing: 16) {
            // Device Icon/Image
            deviceIcon

            // Device Info
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(device.model)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)

                HStack(spacing: 8) {
                    // Category
                    if let categoryName = device.categoryName {
                        Label(categoryName, systemImage: "folder")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Status Badge
                    statusBadge
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Device Icon
    private var deviceIcon: some View {
        Group {
            if let imageUrl = device.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        defaultIcon
                    @unknown default:
                        defaultIcon
                    }
                }
            } else {
                defaultIcon
            }
        }
        .frame(width: 60, height: 60)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }

    private var defaultIcon: some View {
        Image(systemName: deviceIconName)
            .font(.system(size: 24))
            .foregroundColor(.white.opacity(0.7))
    }

    private var deviceIconName: String {
        let category = device.categoryName?.lowercased() ?? ""
        switch category {
        case let c where c.contains("phone") || c.contains("폰"):
            return "iphone"
        case let c where c.contains("tablet") || c.contains("태블릿") || c.contains("pad"):
            return "ipad"
        case let c where c.contains("laptop") || c.contains("노트북"):
            return "laptopcomputer"
        case let c where c.contains("desktop") || c.contains("데스크탑"):
            return "desktopcomputer"
        case let c where c.contains("watch") || c.contains("워치"):
            return "applewatch"
        default:
            return "laptopcomputer.and.iphone"
        }
    }

    // MARK: - Status Badge
    private var statusBadge: some View {
        Text(device.status.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(8)
    }

    private var statusColor: Color {
        switch device.status {
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
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.DMColor.main.ignoresSafeArea()

        VStack {
            DeviceRow(device: Device(
                id: 1,
                companyId: 1,
                name: "MacBook Pro 14인치",
                model: "M3 Pro, 18GB RAM",
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
            ))

            DeviceRow(device: Device(
                id: 2,
                companyId: 1,
                name: "iPhone 15 Pro",
                model: "256GB",
                serialNumber: "XYZ789",
                deviceToken: nil,
                categoryId: 2,
                categoryName: "Phone",
                status: .rented,
                purchaseDate: nil,
                warrantyEndDate: nil,
                description: nil,
                imageUrl: nil,
                specs: nil,
                isFavorite: true,
                currentRental: nil,
                createdAt: nil,
                updatedAt: nil
            ))
        }
        .padding()
    }
}
