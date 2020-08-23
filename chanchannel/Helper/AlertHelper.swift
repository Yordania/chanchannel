//
//  AlertHelper.swift
//  chanchannel
//
//  Created by Odan on 23/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class AlertHelper {
    
    static func showOKAlert(_ title: String?, message: String?, onController controller: UIViewController, onHandleAction: ((UIAlertAction) -> ())?, onComplete: (() -> ())?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: onHandleAction)
        alert.addAction(okAction)
        controller.present(alert, animated: true, completion: onComplete)
    }
    
}
