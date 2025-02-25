//
//  CustomShareLocationPickerView.swift
//  App
//
//  Created by Jarret Hoving on 25/11/2024.
//

import SwiftUI

public struct CustomShareLoationPickerView: View {

    @Binding var locationPickerShown: Bool

    var onDisappear: (() -> Void)

    var onShareLocation: locationCompletion

    let mapView: any ShareCurrentLocationView

    public var body: some View {
        Spacer()
            .fullScreenCover(isPresented: $locationPickerShown) {
                NavigationView {
                    ShareLocationViewComposer.compose(
                        mapView: mapView,
                        locationPickerShown: $locationPickerShown,
                        onDisappear: onDisappear,
                        onShareLocation: onShareLocation
                    )
                }
            }
            .onAppear {
                locationPickerShown = true
            }
            .onChange(of: locationPickerShown) { isShown in
                if !isShown { onDisappear() }
            }
    }
}
