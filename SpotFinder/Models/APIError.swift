//
//  APIError.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation

enum APIError: Error, LocalizedError, Sendable {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(Int, String?)
    case noData
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.APIError.invalidURL
        case .networkError(let error):
            return L10n.APIError.networkError(error.localizedDescription)
        case .invalidResponse:
            return L10n.APIError.invalidResponse
        case .decodingError(let error):
            return L10n.APIError.decodingError(error.localizedDescription)
        case .serverError(let code, let message):
            return L10n.APIError.serverError(code, message ?? L10n.APIError.unknown)
        case .noData:
            return L10n.APIError.noData
        case .unauthorized:
            return L10n.APIError.unauthorized
        case .unknown:
            return L10n.APIError.unknown
        }
    }
}
