//
//  RegisterOrLoginViewModelTests.swift
//  chanchannelTests
//
//  Created by Odan on 26/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import XCTest
import Firebase
@testable import chanchannel

final class RegisterOrLoginViewModelTests: XCTestCase {
    
    func testValidEmail() {
        let viewModel = RegisterOrLoginViewModel()
        
        let validEmail = "johndoe@mail.com"
        XCTAssertTrue(viewModel.isValidEmail(validEmail))
        
        let invalidEmail = "ja,skda@,asdk-"
        XCTAssertFalse(viewModel.isValidEmail(invalidEmail))
    }
    
    func testValidPassword() {
        let viewModel = RegisterOrLoginViewModel()
        
        let validPassword = "12345678"
        XCTAssertTrue(viewModel.isValidPassword(validPassword))
        
        let invalidPassword = "231"
        XCTAssertFalse(viewModel.isValidPassword(invalidPassword))
    }
    
    func testValidName() {
        let viewModel = RegisterOrLoginViewModel()
        
        let validName = "John Doe"
        XCTAssertTrue(viewModel.isValidName(validName))
        
        let invalidName = ""
        XCTAssertFalse(viewModel.isValidName(invalidName))
    }

}
