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
    
    private lazy var accountHelper: AccountHelper = AccountHelper()
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
        let db = Firestore.firestore()
        db.collection("posts").order(by: "createdAt", descending: true).getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
              print("No documents")
              return
            }

            let posts = documents.compactMap { queryDocumentSnapshot -> Post? in
              return try? queryDocumentSnapshot.data(as: Post.self)
            }
            self?.posts = posts
            debugPrint("\(posts)")
            debugPrint(posts.count)
            onComplete?()
        }
    }
    
    func removePost(_ post: Post, onComplete: ((Error?) -> ())?) {
        guard let postId = post.id else {
            onComplete?(nil)
            return
        }
        let db = Firestore.firestore()
        db.collection("posts").document(postId).delete(completion: onComplete)
    }
    
    func isOwnedPost(_ post: Post) -> Bool {
        guard let currentUser = accountHelper.currentUser else { return false }
        return post.userId == currentUser.uid
    }
}
