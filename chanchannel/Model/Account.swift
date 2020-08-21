//
//  Account.swift
//  chanchannel
//
//  Created by Odan on 21/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Account: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
}
