//
//  ChatMessageIntegrationTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 22/01/2025.
//

import Testing
import Foundation
import Amigos_Chat_Package

struct ChatMessageIntegrationTests {

    @Test func doesShowTextMessage() {
        let text = "a message"
        let sut = makeSUT(message: makeMessage(text: text))

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .empty, expectedMessageText: text)
    }

    @Test func doesHandleEmptyMessage() {
        let sut = makeSUT(message: makeMessage())

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .empty, expectedMessageText: "")
    }

    @Test func doesShowImageAttachmentMessage() {
        let sut = makeSUT(message: makeMessage(attachments: [makeImageAttachment()]))

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .image)
    }

    @Test func doesShowVideoAttachmentMessage() {
        let sut = makeSUT(message: makeMessage(attachments: [makeVideoAttachment()]))

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .video)
    }

    @Test func doesShowMultiMediatedAttachmentMessage() {
        let sut = makeSUT(
            message: makeMessage(
                attachments: [makeVideoAttachment(), makeImageAttachment()]
            )
        )

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .multimedia)
    }

    @Test func doesShowMediaAttachmentMessageWhenMultipleAttachmentsArePresentButOnlyOneIsSupported() {
        let sut = makeSUT(
            message: makeMessage(
                attachments: [makeVideoAttachment(), makeImageAttachment(), makeFileAttachment()]
            )
        )

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .multimedia)
    }

    @Test func doesShowQuotedMessageWithMultimediaAttachment() {
        let quotedMessage = makeQuotedMessage(text: "a quoted message")()
        let sut = makeSUT(
            message: makeMessage(
                quotedMessage: { quotedMessage },
                attachments: [makeVideoAttachment(), makeImageAttachment(), makeFileAttachment()]
            )
        )

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .multimedia, expectedQuotedMessage: quotedMessage)
    }

    @Test func doesHandleUnsupportedAttachment() {
        let sut = makeSUT(message: makeMessage(attachments: [makeFileAttachment()]))

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .empty, expectedMessageText: "")
    }

    @Test func doesPrioritizeSupportedAttachmentsOverUnsupported() {
        let sut = makeSUT(
            message: makeMessage(attachments: [makeFileAttachment(), makeImageAttachment()])
        )

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .image)
    }

    @Test func doesHandleLongTextMessage() {
        let longText = String(repeating: "a", count: 10_000)
        let sut = makeSUT(message: makeMessage(text: longText))

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .empty, expectedMessageText: longText)
    }

    @Test func doesHandleInvalidQuotedMessage() {
        let sut = makeSUT(
            message: makeMessage(
                quotedMessage: { nil },
                attachments: [makeImageAttachment()]
            )
        )

        sut.resolveMessageType()

        assertMessageType(sut, expectedAttachmentType: .image, expectedQuotedMessage: nil)
    }

    @Test func doesHandleCombinationOfTextAttachmentsAndQuotedMessage() {
        let quotedMessage = makeQuotedMessage(text: "a quoted message")()
        let sut = makeSUT(
            message: makeMessage(
                text: "a primary message",
                quotedMessage: { quotedMessage },
                attachments: [makeImageAttachment()]
            )
        )

        sut.resolveMessageType()

        assertMessageType(
            sut,
            expectedAttachmentType: .image,
            expectedMessageText: "a primary message",
            expectedQuotedMessage: quotedMessage
        )
    }

    // MARK: Helpers

    private func makeSUT(message: Message) -> MessageViewModel {
        let resolver = MessageTypeResolver(message: message)
        return MessageViewModel(message: message, messageResolver: resolver)
    }

    private func assertMessageType(
        _ sut: MessageViewModel,
        expectedAttachmentType: LocalAttachmentType,
        expectedMessageText: String? = nil,
        expectedQuotedMessage: Message? = nil
    ) {
        #expect(sut.attachmentType == expectedAttachmentType, "Expected view type to be \(expectedAttachmentType), got \(sut.attachmentType) instead")

        if let expectedText = expectedMessageText {
            #expect(sut.messageText == expectedText, "Expected message text to be \(expectedText), got \(sut.messageText) instead")
        }

        if let expectedQuoted = expectedQuotedMessage {
            #expect(sut.quotedMessage == expectedQuoted, "Expected quoted message to be \(expectedQuoted), got \(sut.quotedMessage) instead")
        }
    }
}
