//
//  AssetsColor.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

enum AssetsColor : String {
  case separator
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0.2...0.8),
                       green: .random(in: 0.2...0.8),
                       blue: .random(in: 0.2...0.8),
                       alpha: 1.0)
    }
    
    static func appColor(_ name: AssetsColor) -> UIColor? {
        return UIColor(named: name.rawValue)
    }
}
