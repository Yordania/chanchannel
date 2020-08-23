//
//  TimelinePostCell.swift
//  chanchannel
//
//  Created by Odan on 23/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit
import SkeletonView

final class TimelinePostCell: UITableViewCell {
    
    private let padding: CGFloat = 16
    private let initialViewSize: CGFloat = 44
    
    private lazy var initialView: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.backgroundColor = .systemGray5
        label.clipsToBounds = true
        label.isSkeletonable = true
        return label
    }()
    
    private let containerView = UIView(frame: .zero)
    
    private(set) lazy var authorLabelView: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Author"
        label.isSkeletonable = true
        return label
    }()
    
    private(set) lazy var postLabelView: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 5
        label.text = "Post"
        label.isSkeletonable = true
        return label
    }()
    
    private(set) lazy var dateLabelView: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.text = "Today"
        label.isSkeletonable = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initialView.layer.cornerRadius = initialViewSize / 2
    }
    
    private func setupComponents() {
        isSkeletonable = true
        containerView.isSkeletonable = true
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        contentView.addSubview(initialView)
        contentView.addSubview(containerView)
        containerView.addSubview(authorLabelView)
        containerView.addSubview(postLabelView)
        containerView.addSubview(dateLabelView)
        
        NSLayoutConstraint.layout(visualFormats: ["H:|-[initialView(initialViewSize)]-[containerView]-|",
                                                  "V:|-(padding@999)-[containerView]-(padding@999)-|"],
                                  metrics: ["padding" : padding,
                                            "initialViewSize" : initialViewSize],
                                  views: ["initialView" : initialView,
                                          "containerView" : containerView])
        
        NSLayoutConstraint.layout(visualFormats: ["H:|-[authorLabelView]-|",
                                                  "H:|-[postLabelView]-|",
                                                  "H:|-[dateLabelView]-|",
                                                  "V:|-[authorLabelView]-[postLabelView]-[dateLabelView]-|"],
                                  views: ["authorLabelView" : authorLabelView,
                                          "postLabelView" : postLabelView,
                                          "dateLabelView" : dateLabelView])
        
        initialView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        initialView.heightAnchor.constraint(equalToConstant: initialViewSize).isActive = true
    }
    
    private lazy var personNameFormatter: PersonNameComponentsFormatter = {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        return formatter
    }()

    func setAuthor(_ authorName: String?) {
        authorLabelView.text = authorName
        if let components = personNameFormatter.personNameComponents(from: authorName ?? "") {
            initialView.text = personNameFormatter.string(from: components)
        }
    }
    
}
