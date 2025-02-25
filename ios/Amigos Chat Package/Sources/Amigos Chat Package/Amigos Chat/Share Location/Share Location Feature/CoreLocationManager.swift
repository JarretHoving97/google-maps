//
//  CoreLocationManager.swift
//  App
//
//  Created by Jarret on 02/12/2024.
//

import Foundation
import CoreLocation

public class CoreLocationManager: NSObject, LocationService, CLLocationManagerDelegate {

    private var locationManager = CLLocationManager()

    public var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    public var onAccuracyAuthorizationChange: ((CLAccuracyAuthorization) -> Void)?
    public var onLocationUpdate: ((CLLocation?) -> Void)?

    public var currentLocation: CLLocation? {
        locationManager.location
    }

    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        onAccuracyAuthorizationChange?(manager.accuracyAuthorization)
        onAuthorizationChange?(status)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        onLocationUpdate?(locations.last)
    }
}
