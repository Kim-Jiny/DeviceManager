//
//  APIEndpoint.swift
//  DeviceManager
//

import Foundation

enum APIEndpoint {
    // Base URL
    static let baseURL = "http://kjiny.shop/dm/api"

    // Auth
    case login
    case register
    case refreshToken
    case validateCompany

    // Devices
    case deviceList
    case deviceDetail(id: Int)
    case categories

    // Rentals
    case rentalRequest
    case myRentals
    case returnDevice

    // Admin - Rentals
    case pendingRentals
    case processRental(id: Int)

    // Admin - Devices
    case updateDeviceStatus(id: Int)

    // Admin - Users
    case userList
    case updateUserRole(id: Int)

    // Companies
    case searchCompanies
    case joinCompany

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case .refreshToken:
            return "/auth/refresh"
        case .validateCompany:
            return "/auth/validate-company"
        case .deviceList:
            return "/devices/"
        case .deviceDetail:
            return "/devices"  // Will add /{id} in url property
        case .categories:
            return "/device-categories"
        case .rentalRequest:
            return "/rentals/request"
        case .myRentals:
            return "/rentals/my-rentals"
        case .returnDevice:
            return "/rentals/return"
        case .pendingRentals:
            return "/rentals/pending"
        case .processRental:
            return "/rentals/process"
        case .updateDeviceStatus:
            return "/devices/status"
        case .userList:
            return "/users/list"
        case .updateUserRole:
            return "/users/role"
        case .searchCompanies:
            return "/companies/search"
        case .joinCompany:
            return "/companies/join-request"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .register, .refreshToken, .validateCompany, .rentalRequest, .returnDevice, .joinCompany:
            return .POST
        case .deviceList, .deviceDetail, .categories, .myRentals, .searchCompanies, .pendingRentals, .userList:
            return .GET
        case .processRental, .updateDeviceStatus, .updateUserRole:
            return .PUT
        }
    }

    var url: URL? {
        var urlString = APIEndpoint.baseURL + path

        // Add path or query parameters for requests with IDs
        switch self {
        case .deviceDetail(let id):
            urlString += "/\(id)"  // /devices/1
        case .processRental(let id):
            urlString += "?rental_id=\(id)"
        case .updateDeviceStatus(let id):
            urlString += "?device_id=\(id)"
        case .updateUserRole(let id):
            urlString += "?user_id=\(id)"
        default:
            break
        }

        return URL(string: urlString)
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .register, .validateCompany:
            return false
        default:
            return true
        }
    }
}
