//
//  AccountHelper.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

enum AccountError {
    case generic
    case wrongPassword
    
    var title: String? {
        switch self {
        case .generic:
            return "Something went wrong"
        case .wrongPassword:
            return "It seems you've input a wrong password"
        }
    }
}

protocol AccountHelperProtocol {
    var isUserLogin: Bool { get }
    func getLoginScreen() -> UIViewController
    func loginUser(with email: String, password: String, onComplete: ((AccountError?) -> ())?)
    func logoutUser() throws
}

final class AccountHelper: AccountHelperProtocol {
    private lazy var auth: Auth = Auth.auth()
    
    var isUserLogin: Bool {
        return auth.currentUser != nil
    }
    
    func getLoginScreen() -> UIViewController {
        return LoginVC(viewModel: LoginViewModel())
    }
    
    func loginUser(with email: String, password: String, onComplete: ((AccountError?) -> ())?) {
        auth.signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
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
    
    func logoutUser() throws {
        try auth.signOut()
    }
}
