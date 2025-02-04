//
//  ChatMessagePresentationTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Testing
import SwiftUI

import Amigos_Chat_Package

class ChatMessagePresentationTests {

    @Test func doesInit() {
        let sut = makeSUT()
        #expect(sut != nil)
    }

    @Test func doesPresentMessageTextWhenNotEmpty() {
        let sut = makeSUT(message: Message(message: "a message"))

        #expect(!sut.messageText.isEmpty, "expected to deliver message text. got empty string instead")
    }

    @Test func doesNotPresentMessageTextWhenEmpty() {
        let sut = makeSUT(message: Message(message: ""))

        #expect(sut.messageText.isEmpty, "expected not to deliver message text. got non-empty string instead")
    }

    @Test func doesAppearEmptyAttachmentTypeByDefault() {
        let sut = makeSUT()
        #expect(sut.attachmentType == .empty)
    }

    @Test func doesPresentDeletedWhenMessageIsDeleted() {

        let sut = makeSUT(stub: MessageTypeResolverStub(isDeleted: true))

        sut.resolveMessageType()

        #expect(sut.attachmentType == .deleted, "Expecting to show as deleted. got \(sut.attachmentType) instead")
    }

    @Test func doesPrioritizeDeletedMessageOverAnyAttachmentType() {
        let message = Message(
            attachments: [
                makeImageAttachment(),
                makeImageAttachment(),
                .file(FileAttachment()),
                .link(LinkAttachment(url: URL(string: "http://any-url.com")!)),
                makeVideoAttachment()
            ]
        )

        let sut = makeSUT(message: message, stub: MessageTypeResolverStub(isDeleted: true))

        sut.resolveMessageType()

        #expect(sut.attachmentType == .deleted, "Expecting to show as deleted. got \(sut.attachmentType) instead")
    }

    @Test func doesPresentImageWhenFoundOneImageAttachment() {
        let message = Message(attachments: [makeImageAttachment()])

        let sut = makeSUT(
            message: message,
            stub: MessageTypeResolverStub(hasImageAttachment: true)
        )
        sut.resolveMessageType()

        #expect(sut.attachmentType == .image)
    }

    @Test func doesPresentMultiMediaWhenFoundMultipleImageAttachments() {
        let message = Message(
            attachments: [
                makeImageAttachment(),
                makeImageAttachment()
            ]
        )

        let sut = makeSUT(
            message: message,
            stub: MessageTypeResolverStub(hasImageAttachment: true)
        )
        sut.resolveMessageType()
        #expect(sut.attachmentType == .multimedia)
    }

    @Test func doesPresentVideoWhenFoundOneVideoAttachment() {
        let message = Message(attachments: [makeVideoAttachment()])

        let sut = makeSUT(
            message: message,
            stub: MessageTypeResolverStub(hasVideoAttachment: true)
        )
        sut.resolveMessageType()

        #expect(sut.attachmentType == .video)
    }

    @Test func doesPresentMultiMediaWhenFoundMultipleVideoAttachments() {
        let message = Message(
            attachments: [
                makeVideoAttachment(),
                makeVideoAttachment()
            ]
        )

        let sut = makeSUT(
            message: message,
            stub: MessageTypeResolverStub(hasVideoAttachment: true)
        )

        sut.resolveMessageType()

        #expect(sut.attachmentType == .multimedia)
    }

    @Test func doesPresentMultiMediaWhenFoundImageAndVideoAttachments() {
        let message = Message(
            attachments: [
                makeImageAttachment(),
                makeVideoAttachment()
            ]
        )

        let sut = makeSUT(
            message: message,
            stub: MessageTypeResolverStub(
                hasImageAttachment: true,
                hasVideoAttachment: true
            )
        )

        sut.resolveMessageType()

        #expect(sut.attachmentType == .multimedia)
    }

    @Test func doesPresentEmptyAttachmentWhenNoAttachmentFound() {
        let sut = makeSUT(
            message: Message()
        )

        sut.resolveMessageType()

        #expect(makeSUT().attachmentType == .empty)
    }

    @Test func doesPresentEmptyWhenUnsupportedAttachmentFound() {

        let sut = makeSUT(
            message: Message(attachments: [
                /// files are currently not supported
                .file(FileAttachment())
            ])
        )

        sut.resolveMessageType()

        #expect(makeSUT().attachmentType == .empty)
    }

    @Test func doesPresentEmptyWhenMultipleUnsupportedAttachmentsFound() {
        let sut = makeSUT(
            message: Message(attachments: [
                /// files are currently not supported
                .file(FileAttachment()),
                .file(FileAttachment())
                ]
            )
        )

        sut.resolveMessageType()

        #expect(makeSUT().attachmentType == .empty)
    }

    @Test func doesPresentQuotedMessageWhenNotNil() {
        let sut = makeSUT(
            message: Message(quotedMessage: { Message(message: "This is a quoted message") })
        )

        #expect(sut.quotedMessage != nil, "expected to return a quoted message")
    }

    @Test func doesNotPresentQuotedMessageWhennil() {
        let sut = makeSUT(message: Message())
        #expect(sut.quotedMessage == nil, "do not present a quoted message as its nil ")
    }

    // MARK: Helpers

    private func makeSUT(
        message: Message = Message(),
        stub: MessageTypeResolverStub = MessageTypeResolverStub()
    ) -> MessageViewModel {
        return MessageViewModel(
            message: message,
            messageResolver: stub
        )
    }

}
