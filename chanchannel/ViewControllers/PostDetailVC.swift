//
//  PostDetailVC.swift
//  chanchannel
//
//  Created by Odan on 24/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class PostDetailVC: UITableViewController {
    
    private let viewModel: PostDetailViewModel
    private var isFirstTimeLoad: Bool = true
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    init(viewModel: PostDetailViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    private func setupComponents() {
        tableView.isSkeletonable = true
        tableView.register(TimelinePostCell.self, forCellReuseIdentifier: "postCell")
        tableView.register(TimelinePostCell.self, forCellReuseIdentifier: "postCellSkeleton")
    }
    
    private func reloadData(_ onComplete: (() -> ())? = nil) {
        if isFirstTimeLoad {
            tableView.showAnimatedGradientSkeleton()
            tableView.isUserInteractionEnabled = false
        }
        
        viewModel.getPostDetail { [weak self] error in
            if self?.isFirstTimeLoad == true {
                self?.isFirstTimeLoad = false
                self?.tableView.isUserInteractionEnabled = true
                self?.tableView.hideSkeleton()
            }
            self?.tableView.reloadData()
            onComplete?()
            if let _error = error, let _self = self {
                AlertHelper.showOKAlert(_error.title, message: _error.message, onController: _self, onHandleAction: nil, onComplete: nil)
            }
        }
    }
    
}

extension PostDetailVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !isFirstTimeLoad else {
            return tableView.dequeueReusableCell(withIdentifier: "postCellSkeleton", for: indexPath)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? TimelinePostCell else {
            return UITableViewCell()
        }
        if let post = viewModel.post {
            cell.postLabelView.text = post.body
            cell.postLabelView.numberOfLines = 0
            cell.setAuthor(post.author, color: nil)
            cell.dateLabelView.text = dateFormatter.string(from: post.createdAt.dateValue())
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
