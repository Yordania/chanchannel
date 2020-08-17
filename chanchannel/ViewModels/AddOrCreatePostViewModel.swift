//
//  AddOrCreatePostViewModel.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

final class AddOrCreatePostViewModel {
    var post: Post
    
    init(with post: Post? = nil) {
        if let _post = post {
            self.post = _post
        } else {
            let date = Date()
            self.post = Post(id: UUID().uuidString, body: "", userId: nil, likes: nil, createdAt: Timestamp(date: date), updatedAt: Timestamp(date: date))
        }
    }
    
    func addData() {
        let db = Firestore.firestore()
        let _ = try? db.collection("posts").addDocument(from: post) { (error) in
            guard let _error = error else { return }
            debugPrint("there is an error \(#function) \(_error.localizedDescription)")
        }
    }
}
