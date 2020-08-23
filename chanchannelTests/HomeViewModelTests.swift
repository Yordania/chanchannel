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
    
    class MockUser: User {
        let testingUID: String
        let testingEmail: String?
        let testingDisplayName: String?
        
        init(testingUID: String, testingEmail: String? = nil, testingDisplayName: String? = nil) {
            self.testingUID = testingUID
            self.testingEmail = testingEmail
            self.testingDisplayName = testingDisplayName
        }
    }
    
    class MockDataHelper: DataHelperProtocol {
        private var posts: [Post] = []
        
        var collectionName: String {
            return "unit_testing"
        }
        
        func clearData() {
            posts.removeAll()
        }
        
        func addPost(_ post: Post, onComplete: ((DataError?) -> ())?) {
            posts.append(post)
            onComplete?(nil)
        }
        
        func deletePost(_ post: Post, onComplete: ((DataError?) -> ())?) {
            posts.removeAll(where: { return $0.id == post.id })
            onComplete?(nil)
        }
        
        func getPosts(_ onComplete: (([Post], DataError?) -> ())?) {
            onComplete?(posts, nil)
        }
    }
    
    class MockHomeViewModel: HomeViewModel {
        override init() {
            super.init()
            self.dataHelper = MockDataHelper()
        }
        
        func resetData() {
            dataHelper = MockDataHelper()
        }
    }
    
    private let viewModel = MockHomeViewModel()
    
    func testFetchDataWhenDataIsStillEmpty() {
        viewModel.resetData()
        
        let postsExpectation = expectation(description: "posts")
        var posts: [Post]?
        viewModel.fetchData { [weak self] (erorr) in
            posts = self?.viewModel.posts
            postsExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(posts)
            XCTAssertEqual(posts!.count, 0)
        }
    }
    
    func testFetchDataWith1Post() {
        viewModel.resetData()
        
        let id = UUID().uuidString
        let timeStamp = Timestamp(date: Date())
        let post = Post(id: id, body: "Post1", userId: "userID", author: "user", createdAt: timeStamp, updatedAt: timeStamp)
        viewModel.dataHelper.addPost(post, onComplete: nil)
        
        let postsExpectation = expectation(description: "posts")
        var posts: [Post]?
        viewModel.fetchData { [weak self] (erorr) in
            posts = self?.viewModel.posts
            postsExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(posts)
            XCTAssertEqual(posts!.first!.id!, id)
            XCTAssertEqual(posts!.count, 1)
        }
    }
    
    func testRemoveDataWithFetchData() {
        viewModel.resetData()
        
        let id = UUID().uuidString
        let timeStamp = Timestamp(date: Date())
        let post = Post(id: id, body: "Post1", userId: "userID", author: "user", createdAt: timeStamp, updatedAt: timeStamp)
        viewModel.dataHelper.addPost(post, onComplete: nil)
        
        let postsExpectation = expectation(description: "posts")
        var posts: [Post]?
        viewModel.removePost(post) { [weak self] (error) in
            self?.viewModel.fetchData { (erorr) in
                posts = self?.viewModel.posts
                postsExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(posts)
            XCTAssertEqual(posts!.count, 0)
        }
    }
    
    func testIsOwnedPost() {
        let id = UUID().uuidString
        let userId = "UserId"
        let timeStamp = Timestamp(date: Date())
        let post = Post(id: id, body: "Post1", userId: userId, author: "user", createdAt: timeStamp, updatedAt: timeStamp)
        
    }
    
}
