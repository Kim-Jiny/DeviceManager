//
//  NetworkManager.swift
//  DeviceManager
//

import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, body: Encodable?, queryParams: [String: String]?) async throws -> T
    func request<T: Decodable>(endpoint: APIEndpoint, customRequest: URLRequest) async throws -> T
}

final class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()

    private let session: URLSession
    private let tokenStorage: TokenStorageProtocol

    init(session: URLSession = .shared, tokenStorage: TokenStorageProtocol = TokenStorage.shared) {
        self.session = session
        self.tokenStorage = tokenStorage
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: Encodable? = nil,
        queryParams: [String: String]? = nil
    ) async throws -> T {
        guard var url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        // Add query parameters
        if let queryParams = queryParams, !queryParams.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            var queryItems = components?.queryItems ?? []
            for (key, value) in queryParams {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components?.queryItems = queryItems
            if let newURL = components?.url {
                url = newURL
            }
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if required
        if endpoint.requiresAuth {
            if let token = tokenStorage.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        }

        // Add body for POST/PUT/PATCH
        if let body = body, endpoint.method != .GET {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(body)
        }

        #if DEBUG
        print("🌐 [\(endpoint.method.rawValue)] \(url.absoluteString)")
        if let authHeader = request.value(forHTTPHeaderField: "Authorization") {
            print("🔑 Authorization: \(authHeader)")
        } else {
            print("🔑 Authorization: (none)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📤 Request Body: \(bodyString)")
        }
        #endif

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "Invalid response", code: -1))
            }

            #if DEBUG
            print("📥 Response [\(httpResponse.statusCode)]")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
            }
            #endif

            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    #if DEBUG
                    print("❌ Decoding Error: \(error)")
                    #endif
                    throw NetworkError.decodingError(error)
                }
            case 401:
                tokenStorage.clearToken()
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 404:
                throw NetworkError.notFound
            default:
                // Try to parse error message from response
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse.error ?? errorResponse.message ?? "서버 오류가 발생했습니다.")
                }
                throw NetworkError.serverError("서버 오류가 발생했습니다. (코드: \(httpResponse.statusCode))")
            }
        } catch let error as NetworkError {
            #if DEBUG
            print("❌ Network Error: \(error.localizedDescription)")
            #endif
            throw error
        } catch {
            #if DEBUG
            print("❌ Unknown Error: \(error)")
            #endif
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.networkUnavailable
            }
            throw NetworkError.unknown(error)
        }
    }

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        customRequest: URLRequest
    ) async throws -> T {
        var request = customRequest
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if required
        if endpoint.requiresAuth {
            if let token = tokenStorage.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        }

        #if DEBUG
        print("🌐 [CUSTOM] \(request.url?.absoluteString ?? "")")
        if let authHeader = request.value(forHTTPHeaderField: "Authorization") {
            print("🔑 Authorization: \(authHeader)")
        }
        #endif

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "Invalid response", code: -1))
            }

            #if DEBUG
            print("📥 Response [\(httpResponse.statusCode)]")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
            }
            #endif

            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    #if DEBUG
                    print("❌ Decoding Error: \(error)")
                    #endif
                    throw NetworkError.decodingError(error)
                }
            case 401:
                tokenStorage.clearToken()
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 404:
                throw NetworkError.notFound
            default:
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse.error ?? errorResponse.message ?? "서버 오류가 발생했습니다.")
                }
                throw NetworkError.serverError("서버 오류가 발생했습니다. (코드: \(httpResponse.statusCode))")
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.networkUnavailable
            }
            throw NetworkError.unknown(error)
        }
    }
}

// Helper struct for parsing error responses
private struct APIErrorResponse: Decodable {
    let success: Bool
    let error: String?
    let message: String?
}
