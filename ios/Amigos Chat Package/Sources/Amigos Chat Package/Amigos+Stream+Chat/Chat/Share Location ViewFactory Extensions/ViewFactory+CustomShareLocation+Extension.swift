//
//  ViewFactory+CustomShareLocation+Extension.swift
//  App
//
//  Created by Jarret Hoving on 25/11/2024.
//

import SwiftUI
import StreamChatSwiftUI

extension ViewFactory {

    public typealias CustomShareLocationViewType = CustomShareLoationPickerView

    public func makeCustomShareLocation(
        _ view: any ShareCurrentLocationView,
        locationPickerShown: Binding<Bool>,
        onDissapear: @escaping (() -> Void),
        onShareLocation: @escaping locationCompletion
    ) -> CustomShareLocationViewType {
        CustomShareLocationViewType(
            locationPickerShown: locationPickerShown,
            onDisappear: onDissapear,
            onShareLocation: onShareLocation,
            mapView: view
        )
    }
}
