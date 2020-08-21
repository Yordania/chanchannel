//
//  RegisterOrLoginViewModel.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

final class RegisterOrLoginViewModel {
    
    private lazy var accountHelper: AccountHelper = AccountHelper()
    let minPasswordLength = 8
    var email: String = ""
    var password: String = ""
    var name: String = ""
    
    func doRegister(onComplete: ((AccountError?) -> ())?) {
        accountHelper.registerUser(with: email, password: password) { [weak self] (accountError) in
            if let currentUser = self?.accountHelper.currentUser {
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.displayName = self?.name
                changeRequest.commitChanges(completion: { (error) in
                    if error != nil {
                        onComplete?(.generic)
                    } else {
                        onComplete?(nil)
                    }
                })
            } else {
                onComplete?(accountError)
            }
        }
    }
    
    func doLogin(onComplete: ((AccountError?) -> ())?) {
        accountHelper.loginUser(with: email, password: password, onComplete: onComplete)
    }
    
}
