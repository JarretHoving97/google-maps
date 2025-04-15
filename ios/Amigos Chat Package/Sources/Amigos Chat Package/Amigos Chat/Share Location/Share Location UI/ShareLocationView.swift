//
//  ShareLocationFeature.swift
//  App
//
//  Created by Jarret Hoving on 19/11/2024.
//

import SwiftUI

struct ShareLocationView: View {

    @StateObject private var viewModel: ShareLocationViewModel

    var onCloseTapped: (() -> Void)?

    init(viewModel: ShareLocationViewModel, onCloseTapped: (() -> Void)? = nil) {
        _viewModel =  StateObject(wrappedValue: viewModel)
        self.onCloseTapped = onCloseTapped
    }

    var body: some View {
        mapsView
            .ignoresSafeArea(edges: [.bottom])
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onCloseTapped?()
                    } label: {
                        Image(.xMark)
                            .resizable()
                            .frame(width: 26, height: 26)
                            .tint(Color(.purple))
                    }
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.navigationTitle)

            .onAppear {
                viewModel.requestLocationAuthorization()
            }

    }

    private var mapsView: some View {

        ZStack {
            if let mapView = viewModel.mapView {
                AnyView(mapView)
                    .disabled(true)
            }

            VStack(spacing: 16) {
                ShareCurrentLocationButton(
                    viewModel: viewModel.shareLocationButtonViewData,
                    onTap: onTapAction
                )

                if viewModel.showExactLocationButton {
                    ShareCurrentLocationButton(
                        viewModel: ShareLocationViewModel.grantPreciseLocationAccessViewData,
                        onTap: viewModel.openSettings
                    )
                }

                Spacer()
            }

            .padding(16)

            if viewModel.showLocationSettingsPopover {
                LocationsPermissionsView(
                    action: viewModel.openSettings,
                    closeAction: { viewModel.showLocationSettingsPopover(false) }
                )
            }
        }
    }
    // only close when user can share location.
    private func onTapAction() {
        if viewModel.canShareLocation {
            onCloseTapped?()
        }

        viewModel.shareCurrentLocation()
    }
}
