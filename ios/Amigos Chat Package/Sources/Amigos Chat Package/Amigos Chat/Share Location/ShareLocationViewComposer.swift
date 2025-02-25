//
//  ShareLocationViewComposer.swift
//  App
//
//  Created by Jarret on 02/12/2024.
//

import SwiftUI
import CoreLocation

@MainActor
enum ShareLocationViewComposer {

    static func compose(mapView: any ShareCurrentLocationView, locationPickerShown: Binding<Bool>, onDisappear: @escaping () -> Void, onShareLocation: @escaping locationCompletion) -> ShareLocationSearchWrapperView {

        var mapView = mapView

        let locationService = CoreLocationManager()

        mapView.locationService = locationService

        let viewModel = ShareLocationViewModel(
            shareLocationTapped: onShareLocation
        )

        /// set communications
        mapView.locationService = locationService

        locationService.onLocationUpdate = adaptPresentationForLocationUpdates(viewModel: viewModel)

        locationService.onAuthorizationChange = adaptPresentationForLocationAuthorization(viewModel: viewModel)

        locationService.onAccuracyAuthorizationChange = adaptAccuracyAuthorizationUpdates(viewModel: viewModel)

        /// assign mapview
        viewModel.mapView = mapView

        let shareLocationView = ShareLocationSearchWrapperView(
            viewModel: viewModel,
            isPresenting: locationPickerShown
        )

        return shareLocationView
    }

    private static func adaptPresentationForLocationAuthorization(viewModel: ShareLocationViewModel) -> ((CLAuthorizationStatus) -> Void)? {

        return { [weak viewModel] authState in
            switch authState {

            case .restricted, .denied:
                viewModel?.showLocationSettingsPopover(true)
                viewModel?.canShareLocation = false
                viewModel?.showShareLocationButton(
                    with: ShareLocationViewModel.grantLocationAccesViewData
                )

            default:
                viewModel?.showLocationSettingsPopover(false)
                viewModel?.canShareLocation = true
                viewModel?.showShareLocationButton(with: ShareLocationViewModel.shareLocationUnknownAccuracyViewData)
            }
        }
    }

    private static func adaptPresentationForLocationUpdates(viewModel: ShareLocationViewModel) -> ((CLLocation?) -> Void) {

        return { [weak viewModel] location in

            if let location {
                let meters = Int(round(location.horizontalAccuracy)).description
                viewModel?.showShareLocationButton(with: ShareLocationViewModel.shareLocationViewData(with: meters) )
            }
        }
    }

    private static func adaptAccuracyAuthorizationUpdates(viewModel: ShareLocationViewModel) -> ((CLAccuracyAuthorization) -> Void)? {
        return { [weak viewModel] accuracy in

            viewModel?.showChangeToPreciseLocationAccess(accuracy != .fullAccuracy)
        }
    }
}
