//
//  MockLocationManager.swift
//  App
//
//  Created by Jarret on 02/12/2024.
//

import Foundation
import CoreLocation

class MockLocationManager: LocationService {

    var currentLocation: CLLocation? {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco, CA
            altitude: 30.0,            // Altitude in meters
            horizontalAccuracy: 5.0,   // Horizontal accuracy in meters
            verticalAccuracy: 5.0,     // Vertical accuracy in meters
            course: 90.0,              // Course in degrees
            speed: 10.0,               // Speed in m/s
            timestamp: Date()          // Current date and time
        )
    }

    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?

    var onLocationUpdate: ((CLLocation?) -> Void)?

    func requestAuthorization() {
        onAuthorizationChange?(.denied)
    }

    func startUpdatingLocation() {
        onLocationUpdate?(CLLocation(latitude: 37.7749, longitude: -122.4194))  // Mock location
    }

    func stopUpdatingLocation() {}
}
