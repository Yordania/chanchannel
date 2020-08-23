//
//  DataHelper.swift
//  chanchannel
//
//  Created by Odan on 23/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase

enum DataError: Error {
    case failedToGetPosts
    case failedToAddPost
    case failedToDeletePost
    
    var title: String? {
        return "Something went wrong"
    }
    
    var message: String? {
        return "Please try again"
    }
}

protocol DataHelperProtocol {
    func addPost(_ post: Post, onComplete: ((DataError?) -> ())?)
    func deletePost(_ post: Post, onComplete: ((DataError?) -> ())?)
    func getPosts(_ onComplete: ((_ posts: [Post], DataError?) -> ())?)
}

class DataHelper: DataHelperProtocol {
    
    internal var collectionName: String {
        return "posts"
    }
    
    private lazy var db = Firestore.firestore()
    
    private func getCollection() -> CollectionReference {
        return db.collection(collectionName)
    }
    
    func addPost(_ post: Post, onComplete: ((DataError?) -> ())?) {
        do {
            _ = try getCollection().addDocument(from: post) { (error) in
                guard error == nil else {
                    onComplete?(.failedToAddPost)
                    return
                }
                onComplete?(nil)
            }
        } catch {
            onComplete?(.failedToAddPost)
        }
            
    }
    
    func deletePost(_ post: Post, onComplete: ((DataError?) -> ())?) {
        guard let postId = post.id else {
            onComplete?(nil)
            return
        }
        getCollection().document(postId).delete { (error) in
            guard error == nil else {
                onComplete?(.failedToDeletePost)
                return
            }
            onComplete?(nil)
        }
    }
    
    func getPosts(_ onComplete: ((_ posts: [Post], DataError?) -> ())?) {
        getCollection().order(by: "createdAt", descending: true).getDocuments { (querySnapshot, error) in
            guard error == nil else {
                onComplete?([], .failedToGetPosts)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                onComplete?([], nil)
                return
            }

            let posts = documents.compactMap { queryDocumentSnapshot -> Post? in
                return try? queryDocumentSnapshot.data(as: Post.self)
            }
            onComplete?(posts, nil)
        }
    }
    
}

