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
    
    private lazy var dataHelper: DataHelperProtocol = DataHelper()
    var post: Post
    
    init() {
        let date = Date()
        self.post = Post(id: nil, body: "", userId: nil, author: nil, createdAt: Timestamp(date: date), updatedAt: Timestamp(date: date))
    }
    
    func addData() {
        let accountHelper = AccountHelper()
        post.userId = accountHelper.currentUser?.uid
        post.author = accountHelper.currentUser?.displayName
        dataHelper.addPost(post, onComplete: nil)
    }
    
}
