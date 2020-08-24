//
//  MockClass.swift
//  chanchannelTests
//
//  Created by Odan on 23/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import XCTest
import Firebase
@testable import chanchannel

class MockUser: User {
    var testingUID: String
    var testingEmail: String?
    var testingDisplayName: String?

    init(testingUID: String, testingEmail: String? = nil, testingDisplayName: String? = nil) {
        self.testingUID = testingUID
        self.testingEmail = testingEmail
        self.testingDisplayName = testingDisplayName
    }
}

struct MockFirebaseAccountDataResult: FirebaseAccountServiceResultType {
    var user: User
}

class MockFirebaseAccountService: FirebaseAccountService {
    typealias AuthDataResultType = (authDataResult: FirebaseAccountServiceResultType?, error: Error?)
    var authDataResultFactory: (() -> (AuthDataResultType))?
    var user: User? {
        return authDataResultFactory?().authDataResult?.user
    }

    func signIn(withEmail email: String, password: String, completion: FirebaseAccountServiceCallback?) {
        completion?(authDataResultFactory?().authDataResult, authDataResultFactory?().error)
    }
    
    func createUser(withEmail email: String, password: String, completion: FirebaseAccountServiceCallback?) {
        completion?(authDataResultFactory?().authDataResult, authDataResultFactory?().error)
    }
    
    func signOut() throws {
        if let error = authDataResultFactory?().error {
            throw error
        } else {
            authDataResultFactory = {
                return (nil, nil)
            }
        }
    }
    
    func updateDisplayName(with name: String, completion: UserProfileChangeCallback?) {
        completion?(authDataResultFactory?().error)
    }
}

class MockAccountHelper: AccountHelper {
    override var currentUserId: String? {
        return (currentUser as? MockUser)?.testingUID
    }
}

class MockFirebaseDatabaseService: FirebaseDatabaseService {
    private var posts: [Post]?
    private var error: Error?
    
    init(posts: [Post]? = nil, error: Error? = nil) {
        self.posts = posts
        self.error = error
    }
    
    func addPost(_ post: Post, collectionName: String, completion: ((Error?) -> ())?) {
        if let _error = error {
            completion?(_error)
        } else {
            posts?.append(post)
        }
    }
    
    func deletePost(_ postId: String, collectionName: String, completion: ((Error?) -> ())?) {
        if let _error = error {
            completion?(_error)
        } else {
            posts?.removeAll(where: { return $0.id == postId })
        }
    }
    
    func getPosts(collectionName: String, orderBy: String?, descending: Bool, completion: (([Post], Error?) -> ())?) {
        if let _error = error {
            completion?([], _error)
        } else {
            completion?(posts ?? [], nil)
        }
    }
    
    func getPost(collectionName: String, id: String, completion: ((Post?, Error?) -> ())?) {
        if let _error = error {
            completion?(nil, _error)
        } else {
            completion?(posts?.first(where: { return $0.id == id }), nil)
        }
    }
}
