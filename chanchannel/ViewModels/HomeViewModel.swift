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
    
    var accountHelper: AccountHelperProtocol
    var dataHelper: DataHelperProtocol
    var posts: [Post] = []
    
    init() {
        self.accountHelper = AccountHelper()
        self.dataHelper = DataHelper()
    }
    
    var isUserAlreadyLogin: Bool {
        return accountHelper.isUserLogin
    }
    
    func getLoginScreen() -> RegisterOrLoginVC? {
        return accountHelper.getLoginScreen() as? RegisterOrLoginVC
    }
    
    func logout() throws {
        try accountHelper.logoutUser()
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
