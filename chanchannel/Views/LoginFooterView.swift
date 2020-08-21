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
    private(set) lazy var primaryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray, for: .highlighted)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    private(set) lazy var secondaryButton: UIButton = {
        let button = UIButton(type: .custom)
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
        addSubview(primaryButton)
        addSubview(secondaryButton)
        
        NSLayoutConstraint.layout(visualFormats: ["H:|-[primaryButton]-|",
                                                  "H:|-[secondaryButton]-|",
                                                  "V:|-(padding@999)-[primaryButton(buttonHeight)]-(padding@999)-[secondaryButton(buttonHeight)]-(padding@999)-|"],
                                  metrics: ["buttonHeight" : buttonHeight,
                                            "padding" : padding],
                                  views: ["primaryButton" : primaryButton,
                                          "secondaryButton" : secondaryButton])
    }
    
    func getViewHeight() -> CGFloat {
        return (buttonHeight * 2) + (padding * 3)
    }
    
}
