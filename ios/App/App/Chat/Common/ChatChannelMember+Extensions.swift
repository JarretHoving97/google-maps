import StreamChat
import Foundation

struct Mood {
    private let translationKey: String
    private let expiresAt: String

    public var isActive: Bool
    public var title: String?

    init(translationKey: String, expiresAt: String) async {
        self.translationKey = translationKey
        self.expiresAt = expiresAt

        self.title = nil
        self.isActive = false

        setIsActive()
        await setTitle()
    }

    mutating func setIsActive() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]

        guard let expiresAtDate = formatter.date(from: expiresAt) else {
            isActive = false
            return
        }

        guard Date.now < expiresAtDate else {
            isActive = false
            return
        }

        isActive = true
    }

    mutating func setTitle() async {
        let nameWouldLike = await webViewTranslate("\(translationKey).nameWouldLike", namespace: "interests")

        guard let nameWouldLike else {
            title = nil
            return
        }

        var key = "custom.upFor"

        if !isActive {
            key = "custom.wasUpFor"
        }

        title = tr(key, nameWouldLike)
    }
}

extension ChatChannelMember {
    func getMood() async -> Mood? {
        guard let mood = extraData["mood"]?.dictionaryValue else {
            return nil
        }

        guard let translationKey = mood["translationKey"]?.stringValue else {
            return nil
        }

        guard let expiresAt = mood["expiresAt"]?.stringValue else {
            return nil
        }

        return await Mood(translationKey: translationKey, expiresAt: expiresAt)
    }
}
