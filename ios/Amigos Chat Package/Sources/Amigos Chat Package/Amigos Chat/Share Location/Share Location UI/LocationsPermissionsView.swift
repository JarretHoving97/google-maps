//
//  LocationsPermissionsView.swift
//  App
//
//  Created by Jarret on 03/12/2024.
//

import SwiftUI

struct LocationsPermissionsViewModel {

    var title: String {
        Localized.ShareLocation.enableLocationsPopupTitle
    }

    var buttonTitle: String {
        Localized.ShareLocation.goToSettingsPopupButtonTitle
    }
}

struct LocationsPermissionsView: View {

    private var viewModel = LocationsPermissionsViewModel()
    var action: (() -> Void)?
    var closeAction: (() -> Void)?

    init(viewModel: LocationsPermissionsViewModel = LocationsPermissionsViewModel(), action: (() -> Void)? = nil, closeAction: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.action = action
        self.closeAction = closeAction
    }

    var body: some View {

        let smallNavigationHeight: CGFloat = 80

        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    closeAction?()
                }

            VStack(spacing: 20) {
                Text(viewModel.title)
                    .font(Font.custom(size: 16, weight: .regular))
                    .foregroundStyle(Color(.systemGray5))
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))

                AmiButtonRegular(viewModel.buttonTitle, action: action)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                    .frame(height: 50)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 40)
            .padding(.vertical, smallNavigationHeight) // center to abstract toolbarheight as there is no easy way to display the view over the navigaton controller in swiftUI
        }
    }
}
