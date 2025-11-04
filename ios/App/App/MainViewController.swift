//
//  MainViewController.swift
//  App
//
//  Created by Ilon on 07/02/2025.
//

import CapacitorCommunityGoogleMaps

class MainViewController: CustomMapViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(BranchDeepLinks())
        bridge?.registerPluginInstance(ExtendedBranchPlugin())
        bridge?.registerPluginInstance(ExtendedFacebookPlugin())
        bridge?.registerPluginInstance(ExtendedStreamPlugin())
        bridge?.registerPluginInstance(ExtendedDeviceSettingsPlugin())
    }
}
