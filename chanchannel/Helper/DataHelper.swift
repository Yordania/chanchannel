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
    case failedToGetPost
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
    func getPosts(lastId: String?, limit: Int, onComplete: ((_ posts: [Post], DataError?) -> ())?)
    func getPost(with id: String, onComplete: ((_ posts: Post?, DataError?) -> ())?)
}

protocol FirebaseDatabaseService {
    func addPost(_ post: Post, collectionName: String, completion: ((Error?) -> ())?)
    func deletePost(_ postId: String, collectionName: String, completion: ((Error?) -> ())?)
    func get(collectionName: String, orderBy: String, descending: Bool, limit: Int, lastSnapshot: DocumentSnapshot?, completion: @escaping (([DocumentSnapshot], Error?) -> ()))
    func get(collectionName: String, id: String, completion: @escaping ((DocumentSnapshot?, Error?) -> ()))
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
    
    func get(collectionName: String, orderBy: String, descending: Bool, limit: Int, lastSnapshot: DocumentSnapshot?, completion: @escaping (([DocumentSnapshot], Error?) -> ())) {
        let handlerBlock: FIRQuerySnapshotBlock = { (querySnapshot, error) in
            if let _error = error {
                completion([], _error)
            } else {
                let snapshots = querySnapshot?.documents
                completion(snapshots ?? [], nil)
            }
        }
        
        let collectionSource = collection(collectionName).order(by: orderBy, descending: descending).limit(to: limit)
        if let _lastSnapshot = lastSnapshot {
            collectionSource.start(afterDocument: _lastSnapshot).getDocuments(completion: handlerBlock)
        } else {
            collectionSource.getDocuments(completion: handlerBlock)
        }
    }
    
    func get(collectionName: String, id: String, completion: @escaping ((DocumentSnapshot?, Error?) -> ())) {
        collection(collectionName).document(id).getDocument(completion: completion)
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
    
    func getPosts(lastId: String?, limit: Int, onComplete: ((_ posts: [Post], DataError?) -> ())?) {
        let handlerBlock: ((DocumentSnapshot?, Error?) -> ()) = { [weak self] (snapshot, error) in
            guard error == nil else {
                onComplete?([], .failedToGetPost)
                return
            }
            
            self?.databaseService.get(collectionName: self?.collectionName ?? "", orderBy: "createdAt", descending: true, limit: limit, lastSnapshot: snapshot, completion: { (snapshots, error) in
                guard error == nil else {
                    onComplete?([], .failedToGetPosts)
                    return
                }
                
                let posts = snapshots.compactMap { queryDocumentSnapshot -> Post? in
                    return try? queryDocumentSnapshot.data(as: Post.self)
                }
                onComplete?(posts, nil)
            })
        }
        
        if let _lastId = lastId {
            databaseService.get(collectionName: collectionName, id: _lastId, completion: handlerBlock)
        } else {
            handlerBlock(nil, nil)
        }
    }
    
    func getPost(with id: String, onComplete: ((Post?, DataError?) -> ())?) {
        databaseService.get(collectionName: collectionName, id: id) { (snapshot, error) in
            guard let post = try? snapshot?.data(as: Post.self), error == nil else {
                onComplete?(nil, .failedToGetPost)
                return
            }
            onComplete?(post, nil)
        }
    }
    
}

