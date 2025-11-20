//
//  APIClient.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation
import CoreLocation

actor APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    private init() {
        // Configure with your backend URL
        self.baseURL = "http://100.85.203.36:3000" // Change this to your actual backend URL
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func updateBaseURL(_ url: String) -> APIClient {
        // For production, you might want to create a new instance
        // For now, this is a placeholder
        return self
    }
    
    // MARK: - Nearby Reports
    
    func fetchNearbyReports(latitude: Double, longitude: Double, radius: Double = 500) async throws -> [ParkingReport] {
        let urlString = "\(baseURL)/api/parking-reports/nearby?lat=\(latitude)&lng=\(longitude)&radius=\(radius)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8)
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let reports = try decoder.decode([ParkingReport].self, from: data)
                return reports
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Create Report
    
    func createParkingReport(_ request: CreateParkingReportRequest) async throws -> ParkingReport {
        let urlString = "\(baseURL)/api/parking-reports"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        urlRequest.httpBody = try encoder.encode(request)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8)
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let report = try decoder.decode(ParkingReport.self, from: data)
                return report
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Rate Report
    
    func rateReport(reportId: String, isUpvote: Bool) async throws -> ParkingReport {
        let urlString = "\(baseURL)/api/parking-reports/\(reportId)/rate"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let rateRequest = RateReportRequest(isUpvote: isUpvote)
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(rateRequest)
            
            // Debug: Print the JSON being sent
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Rating request JSON: \(jsonString)")
            }
            
            request.httpBody = jsonData
        } catch {
            print("❌ Failed to encode rating request: \(error)")
            throw APIError.networkError(error)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Rating response [\(httpResponse.statusCode)]: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8)
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let report = try decoder.decode(ParkingReport.self, from: data)
                return report
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
