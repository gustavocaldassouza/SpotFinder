//
//  LocationManager.swift
//  SpotFinder
//
//  Created by Gustavo Caldas de Souza on 2025-11-17.
//

import Foundation
import CoreLocation
import Combine

@MainActor
@Observable
final class LocationManager: NSObject, Sendable {
    private let locationManager = CLLocationManager()
    private(set) var currentLocation: CLLocation?
    private(set) var permissionStatus: LocationPermissionStatus = .notDetermined
    private(set) var error: Error?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    var isAuthorized: Bool {
        permissionStatus.isAuthorized
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .notDetermined:
                permissionStatus = .notDetermined
            case .restricted:
                permissionStatus = .restricted
            case .denied:
                permissionStatus = .denied
            case .authorizedAlways:
                permissionStatus = .authorizedAlways
                startUpdatingLocation()
            case .authorizedWhenInUse:
                permissionStatus = .authorizedWhenInUse
                startUpdatingLocation()
            @unknown default:
                permissionStatus = .notDetermined
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            currentLocation = location
            error = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.error = error
        }
    }
}
