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
  static func appColor(_ name: AssetsColor) -> UIColor? {
     return UIColor(named: name.rawValue)
  }
}
