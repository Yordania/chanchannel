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
    var posts: [Post] = []
    var authorColors: [AuthorColor] = []
    
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
        dataHelper.getPosts(lastId: posts.last?.id, limit: 15) { [weak self] (posts, error) in
            self?.posts.append(contentsOf: posts)
            self?.generateAuthorColors()
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
    
    private func generateAuthorColors() {
        let generatedAuthorColors = posts.filterDuplicate({ $0.userId }).compactMap({ return AuthorColor(id: $0.userId, color: UIColor.random) })
        let filteredGeneratedAuthorColors = generatedAuthorColors.filter { authorColor in
            return !authorColors.contains(where: { return $0.id == authorColor.id })
        }
        authorColors.append(contentsOf: filteredGeneratedAuthorColors)
    }
}
