//
//  LoginFooterView.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class LoginFooterView: UIView {
    
    private let buttonHeight: CGFloat = 44
    private let padding: CGFloat = 16
    private(set) lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Sign-in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray, for: .highlighted)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    private(set) lazy var registerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("I don't have an account yet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray, for: .highlighted)
        button.backgroundColor = .systemTeal
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupComponents() {
        preservesSuperviewLayoutMargins = true
        addSubview(loginButton)
        addSubview(registerButton)
        
        NSLayoutConstraint.layout(visualFormats: ["H:|-[loginButton]-|",
                                                  "H:|-[registerButton]-|",
                                                  "V:|-(padding@999)-[loginButton(buttonHeight)]-(padding@999)-[registerButton(buttonHeight)]-(padding@999)-|"],
                                  metrics: ["buttonHeight" : buttonHeight,
                                            "padding" : padding],
                                  views: ["loginButton" : loginButton,
                                          "registerButton" : registerButton])
    }
    
    func getViewHeight() -> CGFloat {
        return (buttonHeight * 2) + (padding * 3)
    }
    
}
