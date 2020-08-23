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

struct MockFirebaseAuthDataResult: FirebaseAuthDataResultType {
    var user: User
}

class MockFirebaseAuthenticationService: FirebaseAuthenticationType {
    typealias AuthDataResultType = (authDataResult: FirebaseAuthDataResultType?, error: Error?)
    var authDataResultFactory: (() -> (AuthDataResultType))?
    var user: User? {
        return authDataResultFactory?().authDataResult?.user
    }

    func signIn(withEmail email: String, password: String, completion: FirebaseAuthDataResultTypeCallback?) {
        completion?(authDataResultFactory?().authDataResult, authDataResultFactory?().error)
    }
    
    func createUser(withEmail email: String, password: String, completion: FirebaseAuthDataResultTypeCallback?) {
        
    }
    
    func signOut() throws {
        
    }
}

class MockAccountHelper: AccountHelper {
    override var currentUserId: String? {
        return (currentUser as? MockUser)?.testingUID
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
