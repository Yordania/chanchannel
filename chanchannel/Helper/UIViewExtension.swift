//
//  UIViewExtension.swift
//  chanchannel
//
//  Created by Odan on 24/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

extension UIView {
    
    func showLoaderView() {
        let loaderView = LoaderView(frame: bounds)
        loaderView.tag = LoaderView.viewTag
        loaderView.alpha = 0
        addSubview(loaderView)
        
        UIView.animate(withDuration: 0.25) {
            loaderView.alpha = 1
        }
    }
    
    func hideLoaderView(_ completion: (() -> ())? = nil) {
        guard let loaderView = subviews.first(where: { return $0.tag == LoaderView.viewTag }) else {
            completion?()
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            loaderView.alpha = 0
        }) { _ in
            loaderView.removeFromSuperview()
            completion?()
        }
    }
    
}
