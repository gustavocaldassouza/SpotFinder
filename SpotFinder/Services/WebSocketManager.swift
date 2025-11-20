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
        
        // Configure with your backend WebSocket URL
        let urlString = "\(AppConfiguration.wsBaseURL)/api/parking-reports/ws?lat=\(latitude)&lng=\(longitude)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid WebSocket URL")
            return
        }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        reconnectAttempts = 0
        
        receiveMessage()
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
            print("Failed to decode WebSocket message: \(error)")
        }
    }
    
    private func handleDisconnection() {
        isConnected = false
        webSocketTask = nil
        
        // Attempt to reconnect with exponential backoff
        if shouldReconnect && reconnectAttempts < maxReconnectAttempts {
            reconnectAttempts += 1
            let delay = pow(2.0, Double(reconnectAttempts))
            
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                // Note: You'll need to store lat/lng to reconnect
                // For now, this is a placeholder
            }
        }
    }
    
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
}
