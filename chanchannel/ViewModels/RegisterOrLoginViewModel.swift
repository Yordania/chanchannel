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
    
    init(accountHelper: AccountHelperProtocol = AccountHelper()) {
        self.accountHelper = accountHelper
    }
    
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
    
    func isValidEmail(_ email: String) -> Bool {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
      return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
      return password.count >= minPasswordLength
    }
    
    func isValidName(_ name: String) -> Bool {
        return !name.isEmpty
    }
    
}
