//
//  RemoteToLocalMessageMapperTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Testing
import Foundation
import Amigos_Chat_Package

struct RemoteToLocalMessageMapperTests {

    @Test func doesCreatesMessageWithCorrectProperties() {

        let attachmentsTypes: [LocalChatMessageAttachment] = [
            makeImageAttachment(),
            makeVideoAttachment(),
            makeImageAttachment(),
            makeImageAttachment(),
            .file(FileAttachment()
            )
        ]

        let attachments: [ChatMessageAttachmentProtocol] = [
            makeMockAttachment(type: attachmentsTypes[0]),
            makeMockAttachment(type: attachmentsTypes[1]),
            makeMockAttachment(type: attachmentsTypes[2]),
            makeMockAttachment(type: attachmentsTypes[3]),
            makeMockAttachment(type: attachmentsTypes[4])
        ]

        let sut = makeSUT()
        let mockMessage = makeThirdPartyChatMessage(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
            message: "Hello, world!",
            isDeleted: false,
            attachments: attachments
        )

        let result = sut.map(mockMessage)

        #expect(result.id == mockMessage.id)
        #expect(result.isSentByCurrentUser == mockMessage.isSentByCurrentUser)
        #expect(result.text == mockMessage.text)
        #expect(result.isDeleted == mockMessage.isDeleted)
        #expect(result.attachments.count == attachments.count)
        #expect(result.attachments == attachmentsTypes)
    }

    @Test func doesHandleQuotedMessage() {

        let sut = makeSUT()
        let quotedMessage = makeThirdPartyChatMessage(
            id: UUID(uuidString: "987e6543-e21b-34d5-a789-426614174999")!,
            message: "Quoted message",
            isDeleted: false,
            attachments: []
        )

        let mockMessage = makeThirdPartyChatMessage(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
            message: "Main message",
            isDeleted: false,
            attachments: [],
            quotedMessage: quotedMessage
        )

        let result = sut.map(mockMessage)

        #expect(result.quotedMessage != nil)
        #expect(result.quotedMessage?.text == quotedMessage.text)
    }

    @Test func doesHandleNoAttachments() {
        let sut = makeSUT()
        let mockMessage = makeThirdPartyChatMessage(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
            message: "No attachments",
            isDeleted: false,
            attachments: []
        )

        let result = sut.map(mockMessage)

        #expect(result.attachments.isEmpty == true)
    }

    @Test func doesHandleUnsupportedAttachment() {
        // Given
        let sut = makeSUT()
        let mockAttachment = makeMockAttachment(type: .notsupported)
        let mockMessage = makeThirdPartyChatMessage(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
            message: "Unsupported attachment",
            isDeleted: false,
            attachments: [mockAttachment]
        )

        let result = sut.map(mockMessage)

        #expect(result.attachments == [.notsupported])
    }

    // MARK: - Helpers

    private func makeSUT() -> MessageMapper {
        return MessageMapper()
    }

    private func makeThirdPartyChatMessage(
        id: UUID,
        user: LocalUser = LocalUser(
            userId: UUID().uuidString,
            role: Role(rawValue: ""),
            name: "any user"
        ),
        isSentByCurrentUser: Bool = false,
        message: String,
        isDeleted: Bool,
        attachments: [ChatMessageAttachmentProtocol],
        quotedMessage: ChatMessageProtocol? = nil
    ) -> ThirdPartyMessageMock {
        return ThirdPartyMessageMock(
            user: user,
            id: id.uuidString,
            isSentByCurrentUser: isSentByCurrentUser,
            text: message,
            localQuotedMessage: quotedMessage,
            isDeleted: isDeleted,
            attachments: attachments
        )
    }

    private func makeMockAttachment(type: LocalChatMessageAttachment) -> ChatMessageAttachmentProtocol {
        return MockChatMessageAttachment(type: type)
    }

    // MARK: Protocol Mocking

    /// `ChatMessage` from stream is a huge internal object.
    /// Thats why we mimic with the `ChatMessageProtocol` the objects we only need for now
    /// And we can extend `ChatMessage` to this protocol so we know the mocking behaviour will also
    /// work on Stream's `ChatMessage` object
    struct ThirdPartyMessageMock: ChatMessageProtocol {
        var channelId: String
        var actionUrl: String?
        var reactions: [String : Int]
        var textContent: String?
        var messageType: String
        var translationKey: Amigos_Chat_Package.TranslationKey?
        var localPoll: Amigos_Chat_Package.LocalPoll?
        var replyCount: Int
        var localThreadParticipants: [Amigos_Chat_Package.LocalChatUser]
        var textUpdatedAt: Date?
        var layoutKey: String?
        var user: any Author
        var id: String
        var isSentByCurrentUser: Bool
        var text: String
        var localQuotedMessage: (any ChatMessageProtocol)?
        var isDeleted: Bool
        var attachments: [ChatMessageAttachmentProtocol]
        var sendingState: String?
        var createdAt: Date

        init(
            channelId: String = UUID().uuidString,
            actionUrl: String? = nil,
            reactions: [String : Int] = [:],
            textContent: String? = nil,
            messageType: String = "",
            translationKey: Amigos_Chat_Package.TranslationKey? = nil,
            localPoll: Amigos_Chat_Package.LocalPoll? = nil,
            replyCount: Int = 0,
            localThreadParticipants: [Amigos_Chat_Package.LocalChatUser] = [],
            textUpdatedAt: Date? = nil,
            layoutKey: String? = nil,
            user: any Author,
            id: String,
            isSentByCurrentUser: Bool,
            text: String,
            localQuotedMessage: (any ChatMessageProtocol)? = nil,
            isDeleted: Bool,
            attachments: [ChatMessageAttachmentProtocol] = [],
            sendingState: String? = nil,
            createdAt: Date = Date.now
        ) {
            self.channelId = channelId
            self.actionUrl = actionUrl
            self.reactions = reactions
            self.textContent = textContent
            self.messageType = messageType
            self.translationKey = translationKey
            self.localPoll = localPoll
            self.replyCount = replyCount
            self.localThreadParticipants = localThreadParticipants
            self.textUpdatedAt = textUpdatedAt
            self.layoutKey = layoutKey
            self.user = user
            self.id = id
            self.isSentByCurrentUser = isSentByCurrentUser
            self.text = text
            self.localQuotedMessage = localQuotedMessage
            self.isDeleted = isDeleted
            self.attachments = attachments
            self.sendingState = sendingState
            self.createdAt = createdAt
        }
    }

    /// same goes for the `AnyChatMessageAttachment` from Stream.
    struct MockChatMessageAttachment: ChatMessageAttachmentProtocol {
        var localType: LocalChatMessageAttachment

        var payload: Data {
            return Data()
        }

        init(type: LocalChatMessageAttachment) {
            self.localType = type
        }
    }

    private struct LocalUser: Author {
        var userId: String
        var imageURL: URL?
        var role: any AnyRole
        var name: String?
    }

    struct Role: AnyRole {
        var rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue
        }

        init(stringLiteral value: String) {
            self.rawValue = value
        }
    }
}
