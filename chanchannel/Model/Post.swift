//
//  Post.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable, Comparable {
    static func < (lhs: Post, rhs: Post) -> Bool {
        return lhs.createdAt.compare(rhs.createdAt) == .orderedAscending
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs._id == rhs._id
    }
    
    @DocumentID var id: String?
    var body: String
    var userId: String?
    var likes: Int?
    var createdAt: Timestamp
    var updatedAt: Timestamp?
}
