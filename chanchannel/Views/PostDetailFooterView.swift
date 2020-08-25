//
//  PostDetailFooterView.swift
//  chanchannel
//
//  Created by Odan on 25/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class PostDetailFooterView: UIView {
    private let buttonHeight: CGFloat = 44
    private let padding: CGFloat = 16
    private let buttonCornerRadius: CGFloat = 8
    private(set) lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray, for: .highlighted)
        button.backgroundColor = .systemRed
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        deleteButton.layer.cornerRadius = buttonCornerRadius
    }
    
    private func setupComponents() {
        preservesSuperviewLayoutMargins = true
        addSubview(deleteButton)
        
        NSLayoutConstraint.layout(visualFormats: ["H:|-[deleteButton]-|",
                                                  "V:|-(padding@999)-[deleteButton(buttonHeight)]-(padding@999)-|"],
                                  metrics: ["buttonHeight" : buttonHeight,
                                            "padding" : padding],
                                  views: ["deleteButton" : deleteButton])
    }
    
    func getViewHeight() -> CGFloat {
        return buttonHeight + (padding * 2)
    }
}
