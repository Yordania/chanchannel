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
    case generic
    case wrongPassword
    case failedToUpdateName
    case failedToSignOut
    
    var title: String? {
        switch self {
        case .generic:
            return "Something went wrong"
        case .wrongPassword:
            return "It seems you've input a wrong password"
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

protocol FirebaseAuthDataResultType {
    var user: User { get }
}

extension AuthDataResult: FirebaseAuthDataResultType {}

typealias FirebaseAuthDataResultTypeCallback = (FirebaseAuthDataResultType?, Error?) -> ()

protocol FirebaseAuthenticationType {
    var user: User? { get }
    func createUser(withEmail email: String, password: String, completion: FirebaseAuthDataResultTypeCallback?)
    func signIn(withEmail email: String, password: String, completion: FirebaseAuthDataResultTypeCallback?)
    func signOut() throws
}

extension Auth: FirebaseAuthenticationType {
    var user: User? {
        return currentUser
    }
    
    func createUser(withEmail email: String, password: String, completion: FirebaseAuthDataResultTypeCallback?) {
        let completion = completion as AuthDataResultCallback?
        createUser(withEmail: email, password: password, completion: completion)
    }
    
    func signIn(withEmail email: String, password: String, completion: FirebaseAuthDataResultTypeCallback?) {
        let completion = completion as AuthDataResultCallback?
        signIn(withEmail: email, password: password, completion: completion)
    }
}

class AccountHelper: AccountHelperProtocol {
    private let authenticationService: FirebaseAuthenticationType
    
    init(authenticationService: FirebaseAuthenticationType = Auth.auth()) {
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
                onComplete?(.generic)
            }
        }
    }
    
    func updateUsername(with name: String, onComplete: ((AccountError?) -> ())?) {
        guard let _currentUser = currentUser else {
            onComplete?(.failedToUpdateName)
            return
        }
        let changeRequest = _currentUser.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges(completion: { (error) in
            if error != nil {
                onComplete?(.failedToUpdateName)
            } else {
                onComplete?(nil)
            }
        })
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
                    onComplete?(.generic)
                  }
                } else {
                    onComplete?(.generic)
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
