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
    
    struct AuthorColor {
        let id: String?
        let color: UIColor
    }
    
    private let accountHelper: AccountHelperProtocol
    private let dataHelper: DataHelperProtocol
    private var lastSnapshot: DocumentSnapshot?
    private let paginationLimit: Int = 15
    var posts: [Post] = []
    var authorColors: [AuthorColor] = []
    
    init(accountHelper: AccountHelperProtocol = AccountHelper(), dataHelper: DataHelperProtocol = DataHelper()) {
        self.accountHelper = accountHelper
        self.dataHelper = dataHelper
    }
    
    var isUserAlreadyLogin: Bool {
        return accountHelper.isUserLogin
    }
    
    var userDisplayName: String? {
        return accountHelper.currentUser?.displayName
    }
    
    func getLoginScreen() -> RegisterOrLoginVC {
        return RegisterOrLoginVC(viewModel: RegisterOrLoginViewModel(), screenType: .login)
    }
    
    func logout(_ onComplete: ((AccountError?) -> ())?) {
        accountHelper.logoutUser(onComplete)
    }
    
    func fetchData(_ onComplete: ((DataError?) -> ())?) {
        dataHelper.getPosts(lastId: nil, limit: paginationLimit) { [weak self] (posts, error) in
            self?.posts = posts
            self?.generateAuthorColors()
            onComplete?(error)
        }
    }
    
    func fetchPaginationData(_ onComplete: ((DataError?) -> ())?) {
        dataHelper.getPosts(lastId: posts.last?.id, limit: paginationLimit) { [weak self] (posts, error) in
            self?.posts.append(contentsOf: posts)
            self?.generateAuthorColors()
            onComplete?(error)
        }
    }
    
    func removePost(_ post: Post, onComplete: ((DataError?) -> ())?) {
        dataHelper.deletePost(post) { [weak self] (error) in
            guard error == nil else {
                onComplete?(error)
                return
            }
            self?.posts.removeAll(where: { return $0.id == post.id })
            onComplete?(nil)
        }
    }
    
    func isOwnedPost(_ post: Post) -> Bool {
        guard let currentUserId = accountHelper.currentUserId else { return false }
        return post.userId == currentUserId
    }
    
    private func generateAuthorColors() {
        let generatedAuthorColors = posts.filterDuplicate({ $0.userId }).compactMap({ return AuthorColor(id: $0.userId, color: UIColor.random) })
        let filteredGeneratedAuthorColors = generatedAuthorColors.filter { authorColor in
            return !authorColors.contains(where: { return $0.id == authorColor.id })
        }
        authorColors.append(contentsOf: filteredGeneratedAuthorColors)
    }
}
