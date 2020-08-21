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
    var post: Post
    
    init() {
        let date = Date()
        self.post = Post(id: nil, body: "", userId: nil, author: nil, likes: nil, createdAt: Timestamp(date: date), updatedAt: Timestamp(date: date))
    }
    
    func addData() {
        let accountHelper = AccountHelper()
        post.userId = accountHelper.currentUser?.uid
        post.author = accountHelper.currentUser?.displayName
        let db = Firestore.firestore()
        let _ = try? db.collection("posts").addDocument(from: post) { (error) in
            guard let _error = error else { return }
            debugPrint("there is an error \(#function) \(_error.localizedDescription)")
        }
    }
}
