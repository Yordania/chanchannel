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
    var posts: [Post] = []
    
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
    
    func addData(_ data: Post) {
        let db = Firestore.firestore()
        let _ = try? db.collection("posts").addDocument(from: data) { (error) in
            guard let _error = error else { return }
            debugPrint("there is an error \(#function) \(_error.localizedDescription)")
        }
    }
}
