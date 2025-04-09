//
//  ChatNavigationHeaderComposer.swift
//  Amigos Chat Package
//
//  Created by Jarret on 01/04/2025.
//

import SwiftUI
import StreamChat

class ChatNavigationHeaderComposer {

    private init() {}

    public static func setChannelHeader(
        with viewFactory: CustomUIFactory,
        viewModel: ChatChannelScreenViewModel,
        channel: ChatChannel,
        showBackButtonInHeader: Bool = false,
        for detailViewController: UIHostingController<ChatChannelScreen>,
        in navigationController: UINavigationController,
        onMoreTapped: @escaping onMoreTappedAction
    ) {

        // create the navigation item view.
        let titleView = createTitleHeaderView(
            with: viewFactory,
            channel: channel,
            showBackButtonInHeader: showBackButtonInHeader,
            onMoreTapped: onMoreTapped
        )

        // set title view as navigation item
        detailViewController.navigationItem.titleView = titleView
        detailViewController.navigationItem.titleView?.layoutIfNeeded()

        // set title view when header status changes. (e.g. when the channel is updated, to is typing status etc.)
        detailViewController.rootView.onDidLoadChannel = { [weak detailViewController] channel in
            guard let detailViewController else { return }

            let titleView = createTitleHeaderView(
                with: viewFactory,
                channel: channel,
                showBackButtonInHeader: showBackButtonInHeader,
                onMoreTapped: onMoreTapped
            )
            detailViewController.navigationItem.titleView = titleView
            detailViewController.navigationItem.titleView?.layoutIfNeeded()
        }
    }

    private static func createTitleHeaderView(
        with viewFactory: CustomUIFactory,
        channel: ChatChannel,
        showBackButtonInHeader: Bool = false,
        onMoreTapped: @escaping onMoreTappedAction
    ) -> UIView {

        let channelView = CustomChannelHeaderView(
              viewFactory: CustomUIFactory(),
              channel: channel,
              onMoreTapped: onMoreTapped
          )

        let chatTitleView = UIHostingController(
            rootView: channelView
        ).view!

        let width = UIScreen.main.bounds.width

        // title view container
        let titleView = UIView()

        titleView.backgroundColor = .white
        titleView.frame = CGRect(x: 0, y: 0, width: width, height: 50)

        // create a backbutton
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "amiBackButton"), for: .normal)
        backButton.addTarget(self, action: #selector(customBackAction), for: .touchUpInside)

        titleView.hstack(backButton.withWidth(30), chatTitleView.withWidth(width), spacing: showBackButtonInHeader ? 10 : 0)

        /// show the back button when the current view is the `Root viewcontroller` of the `UINavigationcontroller` and the current view has no back button for it's self.
         /// We show the backbutton in this case when we present the chat as root view. (which has no backbutton by default)
        backButton.isHidden = !showBackButtonInHeader

        return titleView

    }

    @objc private static func customBackAction() {
        RouteController.headerDismissButtonAction?(.dismiss)
    }
}
