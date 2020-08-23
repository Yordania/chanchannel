//
//  AccountHelper.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import FirebaseAuth

enum AccountError {
    case failedToSignIn
    case wrongPassword
    case failedToRegister
    case failedToUpdateName
    case failedToSignOut
    
    var title: String? {
        switch self {
        case .failedToSignIn:
            return "Failed to sign in"
        case .wrongPassword:
            return "It seems you've input a wrong password"
        case .failedToRegister:
            return "Failed to register"
        case .failedToUpdateName:
            return "Failed to update name"
        case .failedToSignOut:
            return "Failed to sign out"
        }
    }
}

protocol AccountHelperProtocol {
    var isUserLogin: Bool { get }
    var currentUser: User? { get }
    var currentUserId: String? { get }
    func updateUsername(with name: String, onComplete: ((AccountError?) -> ())?)
    func registerUser(with email: String, password: String, onComplete: ((AccountError?) -> ())?)
    func loginUser(with email: String, password: String, onComplete: ((AccountError?) -> ())?)
    func logoutUser(_ onComplete: ((AccountError?) -> ())?)
}

protocol FirebaseAccountServiceResultType {
    var user: User { get }
}

extension AuthDataResult: FirebaseAccountServiceResultType {}

typealias FirebaseAccountServiceCallback = (FirebaseAccountServiceResultType?, Error?) -> ()

protocol FirebaseAccountService {
    var user: User? { get }
    func createUser(withEmail email: String, password: String, completion: FirebaseAccountServiceCallback?)
    func signIn(withEmail email: String, password: String, completion: FirebaseAccountServiceCallback?)
    func signOut() throws
    func updateDisplayName(with name: String, completion: UserProfileChangeCallback?)
}

extension Auth: FirebaseAccountService {
    var user: User? {
        return currentUser
    }
    
    func createUser(withEmail email: String, password: String, completion: FirebaseAccountServiceCallback?) {
        let completion = completion as AuthDataResultCallback?
        createUser(withEmail: email, password: password, completion: completion)
    }
    
    func signIn(withEmail email: String, password: String, completion: FirebaseAccountServiceCallback?) {
        let completion = completion as AuthDataResultCallback?
        signIn(withEmail: email, password: password, completion: completion)
    }
    
    func updateDisplayName(with name: String, completion: UserProfileChangeCallback?) {
        let changeRequest = currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges(completion: completion)
    }
}

class AccountHelper: AccountHelperProtocol {
    private let authenticationService: FirebaseAccountService
    
    init(authenticationService: FirebaseAccountService = Auth.auth()) {
        self.authenticationService = authenticationService
    }
    
    var isUserLogin: Bool {
        return currentUser != nil
    }
    
    var currentUser: User? {
        return authenticationService.user
    }
    
    var currentUserId: String? {
        return currentUser?.uid
    }
    
    func registerUser(with email: String, password: String, onComplete: ((AccountError?) -> ())?) {
        authenticationService.createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            if self?.isUserLogin == true {
                onComplete?(nil)
            } else {
                onComplete?(.failedToRegister)
            }
        }
    }
    
    func updateUsername(with name: String, onComplete: ((AccountError?) -> ())?) {
        guard isUserLogin else {
            onComplete?(.failedToUpdateName)
            return
        }
        authenticationService.updateDisplayName(with: name) { (error) in
            if error != nil {
                onComplete?(.failedToUpdateName)
            } else {
                onComplete?(nil)
            }
        }
    }
    
    func loginUser(with email: String, password: String, onComplete: ((AccountError?) -> ())?) {
        authenticationService.signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            if self?.isUserLogin == true {
                onComplete?(nil)
            } else {
                if let error = error as NSError? {
                  switch AuthErrorCode(rawValue: error.code) {
                  case .wrongPassword:
                    onComplete?(.wrongPassword)
                  default:
                    onComplete?(.failedToSignIn)
                  }
                } else {
                    onComplete?(.failedToSignIn)
                }
            }
        }
    }
    
    func logoutUser(_ onComplete: ((AccountError?) -> ())?) {
        do {
            try authenticationService.signOut()
            onComplete?(nil)
        } catch {
            onComplete?(.failedToSignOut)
        }
    }
}
