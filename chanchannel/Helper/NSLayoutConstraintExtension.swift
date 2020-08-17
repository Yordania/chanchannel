//
//  NSLayoutConstraintExtension.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    @discardableResult static func layout(visualFormats: [String], options: NSLayoutConstraint.FormatOptions, metrics: [String : Any]?, views: [String : Any]) -> [NSLayoutConstraint] {
        var results: [NSLayoutConstraint] = []
        views.forEach {
            ($0.value as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        }
        visualFormats.forEach {
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: $0, options: options, metrics: metrics, views: views)
            results.append(contentsOf: constraints)
        }
        return results
    }
}
