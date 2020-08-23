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
    case postIdIsNotFound
    
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

typealias FirebaseDatabaseServiceCallback = ([Post], Error?) -> ()

protocol FirebaseDatabaseService {
    func addPost(_ post: Post, collectionName: String, completion: ((Error?) -> ())?)
    func deletePost(_ postId: String, collectionName: String, completion: ((Error?) -> ())?)
    func getPosts(collectionName: String, orderBy: String?, descending: Bool, completion: FirebaseDatabaseServiceCallback?)
}

extension Firestore: FirebaseDatabaseService {
    func addPost(_ post: Post, collectionName: String, completion: ((Error?) -> ())?) {
        do {
            _ = try collection(collectionName).addDocument(from: post, completion: completion)
        } catch {
            completion?(error)
        }
    }
    
    func deletePost(_ postId: String, collectionName: String, completion: ((Error?) -> ())?) {
        collection(collectionName).document(postId).delete(completion: completion)
    }
    
    func getPosts(collectionName: String, orderBy: String? = nil, descending: Bool = false, completion: FirebaseDatabaseServiceCallback?) {
        let handlerBlock: FIRQuerySnapshotBlock = { (querySnapshot, error) in
            if let _error = error {
                completion?([], _error)
            } else {
                let posts = querySnapshot?.documents.compactMap { queryDocumentSnapshot -> Post? in
                    return try? queryDocumentSnapshot.data(as: Post.self)
                }
                completion?(posts ?? [], nil)
            }
        }
        
        let collectionSource = collection(collectionName)
        if let _orderBy = orderBy {
            collectionSource.order(by: _orderBy, descending: descending).getDocuments(completion: handlerBlock)
        } else {
            collectionSource.getDocuments(completion: handlerBlock)
        }
    }
    
    func getPosts(collectionName: String, completion: @escaping (QuerySnapshot?, Error?) -> Void) {
        collection(collectionName).getDocuments(completion: completion)
    }
}

class DataHelper: DataHelperProtocol {
    
    private let databaseService: FirebaseDatabaseService
    private let collectionName: String
    private lazy var db = Firestore.firestore()
    
    init(databaseService: FirebaseDatabaseService = Firestore.firestore(), collectionName: String = "posts") {
        self.databaseService = databaseService
        self.collectionName = collectionName
    }
    
    private func getCollection() -> CollectionReference {
        return db.collection(collectionName)
    }
    
    func addPost(_ post: Post, onComplete: ((DataError?) -> ())?) {
        databaseService.addPost(post, collectionName: collectionName) { (error) in
            guard error == nil else {
                onComplete?(.failedToAddPost)
                return
            }
            onComplete?(nil)
        }
    }
    
    func deletePost(_ post: Post, onComplete: ((DataError?) -> ())?) {
        guard let postId = post.id else {
            onComplete?(.postIdIsNotFound)
            return
        }
        databaseService.deletePost(postId, collectionName: collectionName) { (error) in
            guard error == nil else {
                onComplete?(.failedToDeletePost)
                return
            }
            onComplete?(nil)
        }
    }
    
    func getPosts(_ onComplete: ((_ posts: [Post], DataError?) -> ())?) {
        databaseService.getPosts(collectionName: collectionName, orderBy: "createdAt", descending: true) { (posts, error) in
            guard error == nil else {
                onComplete?([], .failedToGetPosts)
                return
            }
            onComplete?(posts, nil)
        }
    }
    
}

