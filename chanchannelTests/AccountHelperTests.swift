//
//  AccountHelperTests.swift
//  chanchannelTests
//
//  Created by Odan on 23/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import XCTest
import Firebase
@testable import chanchannel

final class AccountHelperTests: XCTestCase {
    
    func testLogin() {
        let firebaseAuthService = MockFirebaseAccountService()
        let expectedUID = "aM1RyjpaZcQ4EhaUvDAeCnla3HX2"
        let expectedEmail = "johndoe@mail.com"
        firebaseAuthService.authDataResultFactory = {
            let user = MockUser(testingUID: expectedUID, testingEmail: expectedEmail)
            let authDataResult = MockFirebaseAccountDataResult(user: user)
            return (authDataResult, nil)
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.loginUser(with: expectedEmail, password: "password") { (error) in
            accountError = error
            accountExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNil(accountError)
            XCTAssertNotNil(accountHelper.currentUser)
            
            let mockUser = accountHelper.currentUser as? MockUser
            XCTAssertNotNil(mockUser)
            
            let testingUID = mockUser!.testingUID
            XCTAssertEqual(testingUID, expectedUID)
            
            let testingEmail = mockUser!.testingEmail
            XCTAssertNotNil(testingEmail)
            XCTAssertEqual(testingEmail!, expectedEmail)
        }
    }
    
    func testErrorLogin() {
        let firebaseAuthService = MockFirebaseAccountService()
        let expectedEmail = "johndoe@mail.com"
        firebaseAuthService.authDataResultFactory = {
            return (nil, NSError(domain: "", code: AuthErrorCode.internalError.rawValue, userInfo: nil))
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.loginUser(with: expectedEmail, password: "password") { (error) in
            accountError = error
            accountExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(accountError)
            XCTAssertEqual(accountError!, AccountError.failedToSignIn)
        }
    }
    
    func testWrongPasswordErrorLogin() {
        let firebaseAuthService = MockFirebaseAccountService()
        let expectedEmail = "johndoe@mail.com"
        firebaseAuthService.authDataResultFactory = {
            return (nil, NSError(domain: "", code: AuthErrorCode.wrongPassword.rawValue, userInfo: nil))
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.loginUser(with: expectedEmail, password: "password") { (error) in
            accountError = error
            accountExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(accountError)
            XCTAssertEqual(accountError!, AccountError.wrongPassword)
        }
    }
    
    func testRegister() {
        let firebaseAuthService = MockFirebaseAccountService()
        let expectedUID = "aM1RyjpaZcQ4EhaUvDAeCnla3HX2"
        let expectedEmail = "johndoe@mail.com"
        firebaseAuthService.authDataResultFactory = {
            let user = MockUser(testingUID: expectedUID, testingEmail: expectedEmail)
            let authDataResult = MockFirebaseAccountDataResult(user: user)
            return (authDataResult, nil)
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.registerUser(with: expectedEmail, password: "password") { (error) in
            accountError = error
            accountExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNil(accountError)
            XCTAssertNotNil(accountHelper.currentUser)
            
            let mockUser = accountHelper.currentUser as? MockUser
            XCTAssertNotNil(mockUser)
            
            let testingUID = mockUser!.testingUID
            XCTAssertEqual(testingUID, expectedUID)
            
            let testingEmail = mockUser!.testingEmail
            XCTAssertNotNil(testingEmail)
            XCTAssertEqual(testingEmail!, expectedEmail)
        }
    }
    
    func testErrorRegister() {
        let firebaseAuthService = MockFirebaseAccountService()
        let expectedEmail = "johndoe@mail.com"
        firebaseAuthService.authDataResultFactory = {
            return (nil, NSError(domain: "", code: AuthErrorCode.internalError.rawValue, userInfo: nil))
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.registerUser(with: expectedEmail, password: "password") { (error) in
            accountError = error
            accountExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(accountError)
            XCTAssertEqual(accountError!, AccountError.failedToRegister)
        }
    }
    
    func testUpdateDisplayName() {
        let firebaseAuthService = MockFirebaseAccountService()
        let expectedUID = "aM1RyjpaZcQ4EhaUvDAeCnla3HX2"
        let expectedEmail = "johndoe@mail.com"
        let expectedName = "John Doe"
        firebaseAuthService.authDataResultFactory = {
            let user = MockUser(testingUID: expectedUID, testingEmail: expectedEmail, testingDisplayName: expectedName)
            let authDataResult = MockFirebaseAccountDataResult(user: user)
            return (authDataResult, nil)
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.updateUsername(with: expectedName, onComplete: { (error) in
            accountError = error
            accountExpectation.fulfill()
        })
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNil(accountError)
            XCTAssertNotNil(accountHelper.currentUser)
            
            let mockUser = accountHelper.currentUser as? MockUser
            XCTAssertNotNil(mockUser)
            
            let testingUID = mockUser!.testingUID
            XCTAssertEqual(testingUID, expectedUID)
            
            let testingEmail = mockUser!.testingEmail
            XCTAssertNotNil(testingEmail)
            XCTAssertEqual(testingEmail!, expectedEmail)
            
            let testingDisplayName = mockUser!.testingDisplayName
            XCTAssertNotNil(testingDisplayName)
            XCTAssertEqual(testingDisplayName!, expectedName)
        }
    }
    
    func testErrorUpdateDisplayName() {
        let firebaseAuthService = MockFirebaseAccountService()
        let expectedName = "John Doe"
        firebaseAuthService.authDataResultFactory = {
            return (nil, NSError(domain: "", code: AuthErrorCode.internalError.rawValue, userInfo: nil))
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.updateUsername(with: expectedName, onComplete: { (error) in
            accountError = error
            accountExpectation.fulfill()
        })
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(accountError)
            XCTAssertEqual(accountError!, AccountError.failedToUpdateName)
        }
    }
    
    func testLogout() {
        let firebaseAuthService = MockFirebaseAccountService()
        let expectedUID = "aM1RyjpaZcQ4EhaUvDAeCnla3HX2"
        let expectedEmail = "johndoe@mail.com"
        firebaseAuthService.authDataResultFactory = {
            let user = MockUser(testingUID: expectedUID, testingEmail: expectedEmail)
            let authDataResult = MockFirebaseAccountDataResult(user: user)
            return (authDataResult, nil)
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.logoutUser({ (error) in
            accountError = error
            accountExpectation.fulfill()
        })
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNil(accountError)
            XCTAssertNil(accountHelper.currentUser)
        }
    }
    
    func testErrorLogout() {
        let firebaseAuthService = MockFirebaseAccountService()
        firebaseAuthService.authDataResultFactory = {
            return (nil, NSError(domain: "", code: AuthErrorCode.internalError.rawValue, userInfo: nil))
        }
        
        let accountExpectation = expectation(description: "account")
        let accountHelper = AccountHelper(authenticationService: firebaseAuthService)
        var accountError: AccountError?
        accountHelper.logoutUser({ (error) in
            accountError = error
            accountExpectation.fulfill()
        })
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(accountError)
            XCTAssertEqual(accountError!, AccountError.failedToSignOut)
        }
    }
    
}
