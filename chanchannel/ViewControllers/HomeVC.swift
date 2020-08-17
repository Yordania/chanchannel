//
//  HomeVC.swift
//  chanchannel
//
//  Created by Odan on 14/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit
import Firebase

final class HomeVC: SuperVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    private func fetchData() {
        let db = Firestore.firestore()
        db.collection("posts").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
              print("No documents")
              return
            }
            
            let posts = documents.compactMap { queryDocumentSnapshot -> Post? in
              return try? queryDocumentSnapshot.data(as: Post.self)
            }
            debugPrint("\(posts)")
        }
    }
    
}
