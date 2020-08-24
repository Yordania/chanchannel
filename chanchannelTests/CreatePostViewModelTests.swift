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
        let expectedPost = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        let mockDataHelper = MockDataHelper(posts: [expectedPost])
        let viewModel = CreatePostViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        
        let addPostExpectation = expectation(description: "add")
        let fetchPostExpectation = expectation(description: "fetch")
        var post: Post?
        viewModel.addData({ (error) in
            addPostExpectation.fulfill()
            mockDataHelper.getPost(with: id) { (_post, error) in
                post = _post
                fetchPostExpectation.fulfill()
            }
        })
        
        let result = XCTWaiter().wait(for: [addPostExpectation, fetchPostExpectation], timeout: 2, enforceOrder: true)
        if result == .completed {
            XCTAssertNotNil(post)
            XCTAssertEqual(post!.id!, id)
        }
    }
    
}
