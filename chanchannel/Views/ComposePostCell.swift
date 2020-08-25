//
//  ComposePostCell.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class ComposePostCell: UITableViewCell {
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private(set) lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .secondarySystemFill
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupComponents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupComponents()
    }
    
    private func setupComponents() {
        let textViewHeight = (textView.font?.lineHeight ?? 8) * CGFloat(5)
        let height = textViewHeight + layoutMargins.top + layoutMargins.bottom
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        NSLayoutConstraint.layout(visualFormats: ["H:|-[titleLabel]-|",
                                                  "H:|-[textView]-|",
                                                  "V:|-[titleLabel]-[textView(height@999)]-|"],
                                  metrics: ["height" : height],
                                  views: ["titleLabel" : titleLabel,
                                          "textView" : textView])
    }
    
}
