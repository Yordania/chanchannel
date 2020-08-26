//
//  PostDetailVC.swift
//  chanchannel
//
//  Created by Odan on 24/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

protocol PostDetailScreenDelegate: AnyObject {
    func postDetailScreenDidRemovePost()
}

final class PostDetailVC: UITableViewController {
    
    private let viewModel: PostDetailViewModel
    private let authorColor: UIColor?
    private var isFirstTimeLoad: Bool = true
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    weak var delegate: PostDetailScreenDelegate?
    
    init(viewModel: PostDetailViewModel, authorColor: UIColor? = nil) {
        self.viewModel = viewModel
        self.authorColor = authorColor
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isFirstTimeLoad {
            tableView.showAnimatedGradientSkeleton()
            tableView.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData { [weak self] in
            DispatchQueue.main.async {
                self?.setupDeleteButton()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    private func setupDeleteButton() {
        if viewModel.isOwnedPost() {
            let footerView = PostDetailFooterView(frame: .zero)
            footerView.alpha = 0
            tableView.tableFooterView = footerView
            tableView.tableFooterView?.frame.size.height = footerView.getViewHeight()
            footerView.deleteButton.setTitle("Delete", for: .normal)
            footerView.deleteButton.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.25) {
                footerView.alpha = 1
            }
        }
    }
    
    private func setupComponents() {
        title = "Post"
        navigationItem.largeTitleDisplayMode = .never
        
        let backBarButton = UIBarButtonItem()
        backBarButton.title = "Back"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backBarButton
        
        tableView.isSkeletonable = true
        tableView.register(TimelinePostCell.self, forCellReuseIdentifier: "postCell")
        tableView.register(TimelinePostCell.self, forCellReuseIdentifier: "postCellSkeleton")
    }
    
    private func reloadData(_ onComplete: (() -> ())? = nil) {
        viewModel.getPostDetail { [weak self] error in
            if self?.isFirstTimeLoad == true {
                self?.isFirstTimeLoad = false
                self?.tableView.isUserInteractionEnabled = true
                self?.tableView.hideSkeleton()
            }
            self?.tableView.reloadSections([0], with: .automatic)
            onComplete?()
            if let _error = error, let _self = self {
                AlertHelper.showOKAlert(_error.title, message: _error.message, onController: _self, onHandleAction: nil, onComplete: nil)
            }
        }
    }
    
    @objc private func deleteButtonDidTap(_ sender: UIButton) {
        viewModel.removePost { [weak self] (error) in
            if let _error = error, let _self = self {
                AlertHelper.showOKAlert(_error.title, message: _error.message, onController: _self, onHandleAction: nil, onComplete: nil)
            } else {
                self?.delegate?.postDetailScreenDidRemovePost()
                self?.navigationController?.popViewController(animated: true)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCellSkeleton", for: indexPath)
            if let _cell = cell as? TimelinePostCell {
                _cell.separatorView.isHidden = true
            }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? TimelinePostCell else {
            return UITableViewCell()
        }
        if let post = viewModel.post {
            cell.postLabelView.text = post.body
            cell.postLabelView.numberOfLines = 0
            cell.setAuthor(post.author, color: authorColor)
            cell.dateLabelView.text = dateFormatter.string(from: post.createdAt.dateValue())
            cell.separatorView.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
