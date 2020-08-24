//
//  PostDetailViewModelTests.swift
//  chanchannelTests
//
//  Created by Odan on 24/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import XCTest
import Firebase
@testable import chanchannel

final class PostDetailViewModelTests: XCTestCase {
    
    private let expectedUID = "aM1RyjpaZcQ4EhaUvDAeCnla3HX2"
    private let expectedEmail = "johndoe@mail.com"
    private let expectedUsername = "John Doe"
    
    func testSuccessGetPost() {
        let id = "Post1"
        let timeStamp = Timestamp(date: Date())
        let expectedPost = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        let mockDatabaseService = MockFirebaseDatabaseService(posts: [expectedPost], error: nil)
        let mockDataHelper = DataHelper(databaseService: mockDatabaseService, collectionName: "unit_testing")
        let viewModel = PostDetailViewModel(dataHelper: mockDataHelper, postId: id)
        
        let postExpectation = expectation(description: "post")
        var post: Post?
        var dataError: DataError?
        viewModel.getPostDetail { (error) in
            post = viewModel.post
            dataError = error
            postExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(post)
            XCTAssertNil(dataError)
            XCTAssertEqual(post!.id!, id)
        }
    }
    
    func testFailedGetPost() {
        let id = "Post1"
        let timeStamp = Timestamp(date: Date())
        let expectedPost = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        let mockDatabaseService = MockFirebaseDatabaseService(posts: [expectedPost], error: nil)
        let mockDataHelper = DataHelper(databaseService: mockDatabaseService, collectionName: "unit_testing")
        let viewModel = PostDetailViewModel(dataHelper: mockDataHelper, postId: "AnotherPostId")
        viewModel.post = expectedPost
        
        let postExpectation = expectation(description: "post")
        var post: Post?
        var dataError: DataError?
        viewModel.getPostDetail { (error) in
            post = viewModel.post
            dataError = error
            postExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNil(post)
            XCTAssertNotNil(dataError)
            XCTAssertEqual(dataError!, DataError.failedToGetPost)
        }
    }
    
    func testSuccessRemovePost() {
        let id = "Post1"
        let timeStamp = Timestamp(date: Date())
        let expectedPost = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        let mockDatabaseService = MockFirebaseDatabaseService(posts: [expectedPost], error: nil)
        let mockDataHelper = DataHelper(databaseService: mockDatabaseService, collectionName: "unit_testing")
        let viewModel = PostDetailViewModel(dataHelper: mockDataHelper, postId: id)
        viewModel.post = expectedPost
        
        let postExpectation = expectation(description: "post")
        var post: Post?
        var dataError: DataError?
        viewModel.removePost { (error) in
            post = viewModel.post
            dataError = error
            postExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNil(post)
            XCTAssertNil(dataError)
        }
    }
    
    func testFailedRemovePost() {
        let id = "Post1"
        let timeStamp = Timestamp(date: Date())
        let expectedPost = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        let mockDatabaseService = MockFirebaseDatabaseService(posts: [expectedPost], error: nil)
        let mockDataHelper = DataHelper(databaseService: mockDatabaseService, collectionName: "unit_testing")
        let viewModel = PostDetailViewModel(dataHelper: mockDataHelper, postId: "AnotherPostId")
        
        let postExpectation = expectation(description: "post")
        var post: Post?
        var dataError: DataError?
        viewModel.removePost { (error) in
            post = viewModel.post
            dataError = error
            postExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(post)
            XCTAssertNotNil(dataError)
            XCTAssertEqual(dataError!, DataError.failedToDeletePost)
        }
    }
    
}
