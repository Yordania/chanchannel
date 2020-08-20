//
//  AccountHelper.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

protocol AccountHelperProtocol {
    var isUserLogin: Bool { get }
    func getLoginScreen() -> UIViewController
}

final class AccountHelper: AccountHelperProtocol {
    private lazy var auth: Auth = Auth.auth()
    
    var isUserLogin: Bool {
        return auth.currentUser != nil
    }
    
    func getLoginScreen() -> UIViewController {
        let navCont = UINavigationController(rootViewController: LoginVC(style: .plain))
        return navCont
    }
}
