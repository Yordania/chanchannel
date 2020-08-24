//
//  ArrayExtension.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
    
    func filterDuplicate<T>(_ keyValue:(Element)->T) -> [Element] {
       var uniqueKeys = Set<String>()
       return filter{uniqueKeys.insert("\(keyValue($0))").inserted}
    }
}
