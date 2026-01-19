//
//  NetworkError.swift
//  DeviceManager
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case forbidden
    case notFound
    case networkUnavailable
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .noData:
            return "데이터를 받지 못했습니다."
        case .decodingError(let error):
            return "데이터 변환 오류: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "인증이 필요합니다."
        case .forbidden:
            return "접근 권한이 없습니다."
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다."
        case .networkUnavailable:
            return "네트워크 연결을 확인해주세요."
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}
