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
    
    private lazy var accountHelper: AccountHelperProtocol = AccountHelper()
    let minPasswordLength = 8
    var email: String = ""
    var password: String = ""
    var name: String = ""
    
    func doRegister(onComplete: ((AccountError?) -> ())?) {
        accountHelper.registerUser(with: email, password: password) { [weak self] (accountError) in
            if let error = accountError {
                onComplete?(error)
            } else {
                self?.accountHelper.updateUsername(with: self?.name ?? "", onComplete: { (error) in
                    onComplete?(error)
                })
            }
        }
    }
    
    func doLogin(onComplete: ((AccountError?) -> ())?) {
        accountHelper.loginUser(with: email, password: password, onComplete: onComplete)
    }
    
}
