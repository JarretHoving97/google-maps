//
//  MessageTypeResolverTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 21/01/2025.
//

import Testing
import Foundation
import Amigos_Chat_Package

struct MessageTypeResolverTests {

    @Test func doesInit() {
        let sut = makeSUT()
        #expect(sut != nil)
    }

    @Test func resolvesAsDeletedWhenMessageIsDeleted() {
        let message = makeMessage(isDeleted: true)
        let sut = makeSUT(with: message)

        #expect(sut.isDeleted())
    }

    @Test func resolvesAsImageAttachmentsWhenMessageHasImageAttachments() {
        let message = makeMessage(attachments: [makeImageAttachment()])
        let sut = makeSUT(with: message)
        #expect(sut.hasImageAttachment())
    }

    @Test func resolvesAsFileAttachmentsWhenMessageHasFileAttachments() {
        let message = makeMessage(attachments: [.file(FileAttachment())])
        let sut = makeSUT(with: message)

        #expect(sut.hasFileAttachment())
    }

    @Test func resolvesAsVideoAttachmentsWhenMessageHasVideoAttachments() {

        let message = makeMessage(attachments: [makeVideoAttachment()])
        let sut = makeSUT(with: message)

        #expect(sut.hasVideoAttachment())
    }

    @Test func resolvesAsLinkAttachmentsWhenMessageHasLinkAttachment() async throws {

        let anyUrl = URL(string: "http://any-url.com")!
        let message = makeMessage(attachments: [.link(LinkAttachment(url: anyUrl))])
        let sut = makeSUT(with: message)

        #expect(sut.hasLinkAttachment())
    }

    // MARK: Helpers

    func makeSUT(with message: Message = Message()) -> MessageTypeResolver {
        return MessageTypeResolver(message: message)
    }
}
