//
//  UserInformationStoreTests.swift
//  Amigos Chat Package
//
//  Created by Jarret on 17/03/2025.
//

import Testing
import Foundation

import Amigos_Chat_Package

struct UserStoreTests {

    @Test func doesInit() async throws {
        let sut = makeSUT()
        #expect(sut != nil)
    }

    @Test func doesRetrieveSameInformationAsStored() async throws {
        let sut = makeSUT()
        let userInfo = makeUserInfo()

        sut.store(info: userInfo)

        try await expect(sut: sut, toRetrieve: userInfo)
    }

    @Test func doesDeleteStoredInformation() async throws {
        let sut = makeSUT()
        let userInfo = makeUserInfo()

        sut.store(info: userInfo)
        sut.clear()

        try await expect(sut: sut, toRetrieve: nil)
    }

    @Test func dataDoesPersistAcrossAppRestarts() async throws {
        let sut = makeSUT()
        let userInfo = makeUserInfo()

        sut.store(info: userInfo)

        let appRestartedSUT = makeSUT()

        try await expect(sut: appRestartedSUT, toRetrieve: userInfo)
    }

    @Test func dataDoesNotPersistWhenDeleted() async throws {
        let sut = makeSUT()
        let userInfo = makeUserInfo()

        sut.store(info: userInfo)
        sut.clear()

        let appRestartedSUT = makeSUT()

        try await expect(sut: appRestartedSUT, toRetrieve: nil)
    }

    @Test func doesReplaceDataOnInsertion() async throws {
        let sut = makeSUT()
        let userInfo1 = makeUserInfo()
        let userInfo2 = makeUserInfo()

        sut.store(info: userInfo1)
        sut.store(info: userInfo2)

        try await expect(sut: sut, toRetrieve: userInfo2)
    }

    // MARK: Helpers
    func expect(sut: UserStore, toRetrieve info: UserData?, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) async throws {

        let retrievedInfo = sut.retrieve()

        #expect(info == retrievedInfo, "expected to retrieve the same information", sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column))
    }

    private func makeSUT(with suitName: String = #function) -> UserStore {
        return UserStore(suiteName: suitName)
    }

    private func makeUserInfo(id: UUID = UUID()) -> UserData {
        return UserData(
            id: id.uuidString,
            imageUrl: "https://profilepictures-dev.amigosapp.nl/public/01aeaaaa-3cc1-4834-82d0-8ae142807ddd.jpg",
            name: "Test User"
        )
    }
}
