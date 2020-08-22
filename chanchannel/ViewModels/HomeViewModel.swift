//
//  HomeViewModel.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

final class HomeViewModel {
    
    private lazy var accountHelper: AccountHelperProtocol = AccountHelper()
    private lazy var dataHelper: DataHelperProtocol = DataHelper()
    var posts: [Post] = []
    
    var isUserAlreadyLogin: Bool {
        return accountHelper.isUserLogin
    }
    
    func getLoginScreen() -> RegisterOrLoginVC? {
        return accountHelper.getLoginScreen() as? RegisterOrLoginVC
    }
    
    func logout() throws {
        try accountHelper.logoutUser()
    }
    
    func fetchData(_ onComplete: (() -> ())? = nil) {
        dataHelper.getPosts { [weak self] (posts, error) in
            self?.posts = posts
            onComplete?()
        }
    }
    
    func removePost(_ post: Post, onComplete: ((DataError?) -> ())?) {
        dataHelper.deletePost(post, onComplete: onComplete)
    }
    
    func isOwnedPost(_ post: Post) -> Bool {
        guard let currentUser = accountHelper.currentUser else { return false }
        return post.userId == currentUser.uid
    }
}
