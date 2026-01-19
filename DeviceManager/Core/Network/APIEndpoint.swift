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
            return "/devices"
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
        case .deviceList, .deviceDetail, .categories, .myRentals, .searchCompanies:
            return .GET
        }
    }

    var url: URL? {
        var urlString = APIEndpoint.baseURL + path

        // Add path parameters for requests with IDs
        switch self {
        case .deviceDetail(let id):
            urlString += "/\(id)"
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
