//
//  HomeViewModelTests.swift
//  chanchannelTests
//
//  Created by Odan on 23/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import XCTest
import Firebase
@testable import chanchannel

final class HomeViewModelTests: XCTestCase {
    
    private let expectedUID = "aM1RyjpaZcQ4EhaUvDAeCnla3HX2"
    private let expectedEmail = "johndoe@mail.com"
    private let expectedUsername = "John Doe"
    private var mockLoginAuthService: FirebaseAuthenticationType {
        let firebaseAuthService = MockFirebaseAuthenticationService()
        firebaseAuthService.authDataResultFactory = { [weak self] in
            let user = MockUser(testingUID: self?.expectedUID ?? "", testingEmail: self?.expectedEmail)
            let authDataResult = MockFirebaseAuthDataResult(user: user)
            return (authDataResult, nil)
        }
        return firebaseAuthService
    }
    private var mockNotLoginAuthService: FirebaseAuthenticationType {
        let firebaseAuthService = MockFirebaseAuthenticationService()
        return firebaseAuthService
    }
    
    func testFetchDataWhenDataIsStillEmpty() {
        let mockAccountHelper = MockAccountHelper(authenticationService: mockLoginAuthService)
        let mockDataHelper = MockDataHelper()
        let viewModel = HomeViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        let postsExpectation = expectation(description: "posts")
        var posts: [Post]?
        viewModel.fetchData { (erorr) in
            posts = viewModel.posts
            postsExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(posts)
            XCTAssertEqual(posts!.count, 0)
        }
    }
    
    func testFetchDataWith1Post() {
        let mockAccountHelper = MockAccountHelper(authenticationService: mockLoginAuthService)
        let mockDataHelper = MockDataHelper()
        let viewModel = HomeViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        
        let id = UUID().uuidString
        let timeStamp = Timestamp(date: Date())
        let post = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        mockDataHelper.addPost(post, onComplete: nil)
        
        let postsExpectation = expectation(description: "posts")
        var posts: [Post]?
        viewModel.fetchData { (erorr) in
            posts = viewModel.posts
            postsExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(posts)
            XCTAssertEqual(posts!.first!.id!, id)
            XCTAssertEqual(posts!.count, 1)
        }
    }
    
    func testRemoveDataWithFetchData() {
        let mockAccountHelper = MockAccountHelper(authenticationService: mockLoginAuthService)
        let mockDataHelper = MockDataHelper()
        let viewModel = HomeViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        
        let id = UUID().uuidString
        let timeStamp = Timestamp(date: Date())
        let post = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        mockDataHelper.addPost(post, onComplete: nil)
        
        let postsExpectation = expectation(description: "posts")
        var posts: [Post]?
        viewModel.removePost(post) { (error) in
            viewModel.fetchData { (erorr) in
                posts = viewModel.posts
                postsExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(posts)
            XCTAssertEqual(posts!.count, 0)
        }
    }
    
    func testIsOwnedPost() {
        let mockAccountHelper = MockAccountHelper(authenticationService: mockLoginAuthService)
        let mockDataHelper = MockDataHelper()
        let viewModel = HomeViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        
        let id = UUID().uuidString
        let timeStamp = Timestamp(date: Date())
        let post = Post(id: id, body: "Post1", userId: expectedUID, author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        
        XCTAssertTrue(viewModel.isOwnedPost(post))
    }
    
    func testIsNotOwnedPost() {
        let mockAccountHelper = MockAccountHelper(authenticationService: mockLoginAuthService)
        let mockDataHelper = MockDataHelper()
        let viewModel = HomeViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        
        let id = UUID().uuidString
        let timeStamp = Timestamp(date: Date())
        let post = Post(id: id, body: "Post1", userId: "notThisUser", author: expectedUsername, createdAt: timeStamp, updatedAt: timeStamp)
        
        XCTAssertFalse(viewModel.isOwnedPost(post))
    }
    
    func testIsUserLogin() {
        let mockAccountHelper = MockAccountHelper(authenticationService: mockLoginAuthService)
        let mockDataHelper = MockDataHelper()
        let viewModel = HomeViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        
        XCTAssertTrue(viewModel.isUserAlreadyLogin)
    }
    
    func testIsUserNotLogin() {
        let mockAccountHelper = MockAccountHelper(authenticationService: mockNotLoginAuthService)
        let mockDataHelper = MockDataHelper()
        let viewModel = HomeViewModel(accountHelper: mockAccountHelper, dataHelper: mockDataHelper)
        
        XCTAssertFalse(viewModel.isUserAlreadyLogin)
    }
    
}
