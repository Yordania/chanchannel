//
//  PostDetailViewModel.swift
//  chanchannel
//
//  Created by Odan on 24/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation

final class PostDetailViewModel {
    
    private let dataHelper: DataHelperProtocol
    private let postId: String
    var post: Post?
    
    init(dataHelper: DataHelperProtocol = DataHelper(), postId: String) {
        self.dataHelper = dataHelper
        self.postId = postId
    }
    
    func getPostDetail(_ onComplete: ((DataError?) -> ())?) {
        dataHelper.getPost(with: postId) { [weak self] (post, error) in
            self?.post = post
            onComplete?(error)
        }
    }
    
    func removePost(onComplete: ((DataError?) -> ())?) {
        guard let _post = post else {
            onComplete?(.failedToDeletePost)
            return
        }
        dataHelper.deletePost(_post) { [weak self] error in
            if error == nil {
                self?.post = nil
            }
            onComplete?(error)
        }
    }
    
}
