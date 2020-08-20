//
//  LoginViewModel.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation

final class LoginViewModel {
    
    private lazy var accountHelper: AccountHelper = AccountHelper()
    var email: String = ""
    var password: String = ""
    
    func doLogin(onComplete: ((AccountError?) -> ())?) {
        accountHelper.loginUser(with: email, password: password, onComplete: onComplete)
    }
    
}
