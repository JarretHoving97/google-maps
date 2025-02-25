//
//  LocationService.swift
//  App
//
//  Created by Jarret on 02/12/2024.
//

import Foundation
import CoreLocation

public protocol LocationService {

    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)? { get set }
    var onLocationUpdate: ((CLLocation?) -> Void)? { get set }

    var currentLocation: CLLocation? { get }

    func requestAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
