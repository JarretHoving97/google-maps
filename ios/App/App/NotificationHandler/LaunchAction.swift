enum LaunchAction {

    case streamChat(ChannelInfo)

    typealias UserInfo = [AnyHashable: Any]
}

extension LaunchAction {

    // configure action cases here
    static func create(for info: UserInfo) -> LaunchAction? {
        if info["sender"] as? String == "stream.chat", let message = info["message_id"] as? String, let channel = info["cid"] as? String {
            return .streamChat(ChannelInfo(messageId: message, channelId: channel))
        }

        return nil
    }
}
