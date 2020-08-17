//
//  ComposePostCell.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class ComposePostCell: UITableViewCell {
    private(set) lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: 16)
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
        contentView.addSubview(textView)
        NSLayoutConstraint.layout(visualFormats: ["H:|-[textView]-|",
                                                  "V:|-[textView(height@999)]-|"],
                                  metrics: ["height" : height],
                                  views: ["textView" : textView])
    }
}
