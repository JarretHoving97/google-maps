//
//  ShareLocationViewModel.swift
//  App
//
//  Created by Jarret Hoving on 19/11/2024.
//

import SwiftUI
import CoreLocation

public protocol ShareCurrentLocationView: View {

    var locationService: LocationService { get set }

}

public typealias locationCompletion = ((CLLocation?) -> Void)

@MainActor
class ShareLocationViewModel: ObservableObject {

    @Published private(set) var shareLocationButtonViewData: ShareCurrentLocationViewModel

    @Published private(set) var showGoToSettingsPopup: Bool = false

    @Published private(set) var showLocationSettingsPopover: Bool = false

    @Published private(set) var showExactLocationButton: Bool = false

    var mapView: (any ShareCurrentLocationView)?

    private var shareLocationTapped: locationCompletion

    var canShareLocation: Bool = false

    var navigationTitle: String {
        return Localized.ShareLocation.title
    }

    init(shareLocationTapped: @escaping locationCompletion) {
        self.shareLocationTapped = shareLocationTapped
        self.shareLocationButtonViewData = ShareLocationViewModel.shareLocationUnknownAccuracyViewData
    }

    func requestLocationAuthorization() {
        mapView?.locationService.requestAuthorization()
    }

    func shareCurrentLocation() {
        !canShareLocation ? openSettings() : shareLocationTapped(mapView?.locationService.currentLocation)
    }

    func showShareLocationButton(with data: ShareCurrentLocationViewModel) {
        withAnimation {
            self.shareLocationButtonViewData = data
        }
    }

    func presentGoToSettings(_ show: Bool) {
        withAnimation {
            showGoToSettingsPopup = show
        }
    }

    func showLocationSettingsPopover(_ show: Bool) {
        withAnimation {
            showLocationSettingsPopover = show
        }
    }

    func showChangeToPreciseLocationAccess(_ show: Bool) {
        withAnimation {
            showExactLocationButton = show
        }
    }

    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}

// MARK: labels
extension ShareLocationViewModel {

    static var grantLocationAccesViewData: ShareCurrentLocationViewModel {
        ShareCurrentLocationViewModel(
            title: Localized.ShareLocation.grantLocationAccessTitle
        )
    }

    static var grantPreciseLocationAccessViewData: ShareCurrentLocationViewModel {
        ShareCurrentLocationViewModel(
            title: Localized.ShareLocation.enablePreciseLocationButtonTitle
        )
    }

    static var shareLocationUnknownAccuracyViewData: ShareCurrentLocationViewModel {
        ShareCurrentLocationViewModel(
            title: Localized.ShareLocation.shareYourLocationLabel,
            subtitle: Localized.ShareLocation.accuracyUnknownSubtitle
        )
    }

    static func shareLocationViewData(with meters: String) -> ShareCurrentLocationViewModel {
        ShareCurrentLocationViewModel(
            title: Localized.ShareLocation.shareYourLocationLabel,
            subtitle: Localized.ShareLocation.accuracyInMetersSubtitle(meters: meters)
        )
    }
}
