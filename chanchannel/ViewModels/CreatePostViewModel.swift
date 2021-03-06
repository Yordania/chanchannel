//
//  CreatePostViewModel.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

final class CreatePostViewModel {
    
    private let accountHelper: AccountHelperProtocol
    private let dataHelper: DataHelperProtocol
    var post: Post
    
    init(accountHelper: AccountHelperProtocol = AccountHelper(), dataHelper: DataHelperProtocol = DataHelper()) {
        self.accountHelper = accountHelper
        self.dataHelper = dataHelper
        let date = Date()
        self.post = Post(id: nil, body: "", userId: nil, author: nil, createdAt: Timestamp(date: date), updatedAt: Timestamp(date: date))
    }
    
    var userDisplayName: String? {
        return accountHelper.currentUser?.displayName
    }
    
    func addData(_ onComplete: ((DataError?) -> ())?) {
        post.userId = accountHelper.currentUser?.uid
        post.author = accountHelper.currentUser?.displayName
        dataHelper.addPost(post, onComplete: onComplete)
    }
    
}
