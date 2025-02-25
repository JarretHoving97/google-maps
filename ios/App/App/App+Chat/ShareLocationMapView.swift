//
//  Untitled.swift
//  App
//
//  Created by Jarret Hoving on 22/11/2024.
//

import CoreLocation
import SwiftUI
import GoogleMaps
import Amigos_Chat_Package
import UIKit

extension ShareLocationMapView {
    static let standardMapZoom: Float = 18.0
}

struct ShareLocationMapView: ShareCurrentLocationView, UIViewRepresentable {

    var locationService: LocationService

    // Make coordinator
    func makeCoordinator() -> Coordinator {
        return Coordinator(locationService: locationService)
    }

    // Make UIView
    func makeUIView(context: Context) -> GMSMapView {

        let mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        context.coordinator.mapView = mapView

        if let location = context.coordinator.locationService.currentLocation {
            let camera = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                zoom: ShareLocationMapView.standardMapZoom
            )

            mapView.animate(to: camera)
        }

        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {}
}

extension ShareLocationMapView {
    // Coordinator to handle events
    class Coordinator {

        var locationService: LocationService

        var mapView: GMSMapView?

        private var didUpdateForCurrentLocation: Bool = false

        init(locationService: LocationService) {
            self.locationService = locationService
        }
    }
}
