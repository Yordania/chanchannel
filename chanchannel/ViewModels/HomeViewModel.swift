//
//  HomeViewModel.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

class HomeViewModel {
    
    private var accountHelper: AccountHelperProtocol
    private var dataHelper: DataHelperProtocol
    var posts: [Post] = []
    
    init(accountHelper: AccountHelperProtocol = AccountHelper(), dataHelper: DataHelperProtocol = DataHelper()) {
        self.accountHelper = accountHelper
        self.dataHelper = dataHelper
    }
    
    var isUserAlreadyLogin: Bool {
        return accountHelper.isUserLogin
    }
    
    func getLoginScreen() -> RegisterOrLoginVC {
        return RegisterOrLoginVC(viewModel: RegisterOrLoginViewModel(), screenType: .login)
    }
    
    func logout(_ onComplete: ((AccountError?) -> ())?) {
        accountHelper.logoutUser(onComplete)
    }
    
    func fetchData(_ onComplete: ((DataError?) -> ())? = nil) {
        dataHelper.getPosts { [weak self] (posts, error) in
            self?.posts = posts
            onComplete?(error)
        }
    }
    
    func removePost(_ post: Post, onComplete: ((DataError?) -> ())?) {
        dataHelper.deletePost(post, onComplete: onComplete)
    }
    
    func isOwnedPost(_ post: Post) -> Bool {
        guard let currentUserId = accountHelper.currentUserId else { return false }
        return post.userId == currentUserId
    }
}
