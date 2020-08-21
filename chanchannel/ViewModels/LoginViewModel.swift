//
//  LoginViewModel.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

final class LoginViewModel {
    
    private lazy var accountHelper: AccountHelper = AccountHelper()
    let minPasswordLength = 8
    var email: String = ""
    var password: String = ""
    var name: String = ""
    
    func doRegister(onComplete: ((AccountError?) -> ())?) {
        accountHelper.registerUser(with: email, password: password) { [weak self] (error) in
            let db = Firestore.firestore()
            if let currentUser = self?.accountHelper.currentUser {
                let account = Account(id: currentUser.uid, name: self?.name ?? "")
                try? db.collection("users").document(currentUser.uid).setData(from: account)
            }
            onComplete?(error)
        }
    }
    
    func doLogin(onComplete: ((AccountError?) -> ())?) {
        accountHelper.loginUser(with: email, password: password, onComplete: onComplete)
    }
    
}
