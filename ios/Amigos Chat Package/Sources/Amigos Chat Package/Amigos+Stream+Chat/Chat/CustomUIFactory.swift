import SwiftUI
import Photos
import StreamChat
import StreamChatSwiftUI

public typealias routeAction = ((RouteInfo) -> Void)

public class CustomUIFactory {
    @Injected(\.utils) public var utils
    @Injected(\.chatClient) public var chatClient

    public init() {}
}


