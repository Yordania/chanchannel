//
//  LoginHeaderView.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class LoginHeaderView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupComponents() {
        titleLabel.text = "Welcome to Chanchannel!"
        addSubview(titleLabel)
        NSLayoutConstraint.layout(visualFormats: ["H:|-[titleLabel]-|"],
                                  views: ["titleLabel" : titleLabel])
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
