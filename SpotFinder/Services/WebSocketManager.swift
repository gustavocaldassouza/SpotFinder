//
//  WebSocketManager.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation
import Combine

@MainActor
@Observable
final class WebSocketManager: NSObject, Sendable {
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession
    private var isConnected = false
    private var shouldReconnect = true
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    
    let reportPublisher = PassthroughSubject<ParkingReport, Never>()
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: configuration)
        super.init()
    }
    
    func connect(latitude: Double, longitude: Double) {
        guard !isConnected else { return }
        
        let urlString = "\(AppConfiguration.wsBaseURL)/api/parking-reports/ws?lat=\(latitude)&lng=\(longitude)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        
        // Attach authentication token if available
        Task {
            if let token = await AuthService.shared.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            webSocketTask = session.webSocketTask(with: request)
            webSocketTask?.resume()
            isConnected = true
            reconnectAttempts = 0
            
            receiveMessage()
        }
    }
    
    func disconnect() {
        shouldReconnect = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        self.handleReceivedData(data)
                    case .string(let text):
                        guard let data = text.data(using: .utf8) else { return }
                        self.handleReceivedData(data)
                    @unknown default:
                        break
                    }
                    
                    // Continue receiving messages
                    self.receiveMessage()
                    
                case .failure(let error):
                    print("WebSocket receive error: \(error)")
                    self.handleDisconnection()
                }
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let report = try decoder.decode(ParkingReport.self, from: data)
            reportPublisher.send(report)
        } catch {
            return
        }
    }
    
    private func handleDisconnection() {
        isConnected = false
        webSocketTask = nil
        
        if shouldReconnect && reconnectAttempts < maxReconnectAttempts {
            reconnectAttempts += 1
            let delay = pow(2.0, Double(reconnectAttempts))
            
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
    
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { _ in }
    }
}
