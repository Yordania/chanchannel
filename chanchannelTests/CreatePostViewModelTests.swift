//
//  CreatePostViewModelTests.swift
//  chanchannelTests
//
//  Created by Odan on 23/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import XCTest
import Firebase
@testable import chanchannel

final class CreatePostViewModelTests: XCTestCase {
    
    private let expectedUID = "aM1RyjpaZcQ4EhaUvDAeCnla3HX2"
    private let expectedEmail = "johndoe@mail.com"
    private let expectedUsername = "John Doe"
    private var mockLoginAccountService: FirebaseAccountService {
        let firebaseAccountService = MockFirebaseAccountService()
        firebaseAccountService.authDataResultFactory = { [weak self] in
            let user = MockUser(testingUID: self?.expectedUID ?? "", testingEmail: self?.expectedEmail)
            let authDataResult = MockFirebaseAccountDataResult(user: user)
            return (authDataResult, nil)
        }
        return firebaseAccountService
    }
    
    func testAddPost() {
        let mockAccountHelper = MockAccountHelper(authenticationService: mockLoginAccountService)
        let id = "Post1"
        let timeStamp = Timestamp(date: Date())
        let post = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        let mockDatabaseService = MockFirebaseDatabaseService(posts: [post], error: nil)
        let mockDataHelper = DataHelper(databaseService: mockDatabaseService, collectionName: "unit_testing")
        let viewModel = CreatePostViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        
        let addPostExpectation = expectation(description: "add")
        let fetchPostExpectation = expectation(description: "fetch")
        var posts: [Post]?
        viewModel.addData({ (error) in
            addPostExpectation.fulfill()
            mockDataHelper.getPosts { (_posts, error) in
                posts = _posts
                fetchPostExpectation.fulfill()
            }
        })
        
        let result = XCTWaiter().wait(for: [addPostExpectation, fetchPostExpectation], timeout: 2, enforceOrder: true)
        if result == .completed {
            XCTAssertNotNil(posts)
            XCTAssertEqual(posts!.count, 1)
            XCTAssertEqual(posts!.first!.id!, id)
        }
    }
    
}
