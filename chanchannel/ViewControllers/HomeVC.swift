//
//  HomeVC.swift
//  chanchannel
//
//  Created by Odan on 14/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit
import Firebase

final class HomeVC: UITableViewController {
    
    private let viewModel: HomeViewModel
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
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
        setupLeftBarButtonItems()
        reloadData()
    }
    
    private func setupComponents() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidTap))
        
        tableView.register(TimelinePostCell.self, forCellReuseIdentifier: "postCell")
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Reloading")
        refreshControl?.addTarget(self, action: #selector(pullToRefreshDidInitate), for: .valueChanged)
    }
    
    private func setupLeftBarButtonItems() {
        if viewModel.isUserAlreadyLogin {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "SignOut", style: .done, target: self, action: #selector(logoutButtonDidTap))
        }
    }
    
    private func reloadData(_ onComplete: (() -> ())? = nil) {
        viewModel.fetchData() { [weak self] error in
            self?.tableView.reloadData()
            onComplete?()
            if let _error = error, let _self = self {
                AlertHelper.showOKAlert(_error.title, message: _error.message, onController: _self, onHandleAction: nil, onComplete: nil)
            }
        }
    }
    
    @objc private func pullToRefreshDidInitate(_ sender: UIRefreshControl) {
        reloadData {
            sender.endRefreshing()
        }
    }
    
    @objc private func addButtonDidTap(_ sender: UIBarButtonItem) {
        guard viewModel.isUserAlreadyLogin else {
            let loginVC = viewModel.getLoginScreen()
            loginVC.delegate = self
            let navCont = UINavigationController(rootViewController: loginVC)
            present(navCont, animated: true, completion: nil)
            return
        }
        let vc = CreatePostVC(viewModel: CreatePostViewModel())
        let navCont = UINavigationController(rootViewController: vc)
        navigationController?.present(navCont, animated: true, completion: nil)
    }
    
    @objc private func logoutButtonDidTap(_ sender: UIBarButtonItem) {
        viewModel.logout { [weak self] (error) in
            if let _error = error, let _self = self {
                AlertHelper.showOKAlert(_error.title, message: nil, onController: _self, onHandleAction: nil, onComplete: nil)
            } else {
                self?.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
}

extension HomeVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? TimelinePostCell else {
            return UITableViewCell()
        }
        if let post = viewModel.posts[safe: indexPath.row] {
            cell.postLabelView.text = post.body
            cell.setAuthor(post.author)
            cell.dateLabelView.text = dateFormatter.string(from: post.createdAt.dateValue())
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let post = viewModel.posts[safe: indexPath.row],
            viewModel.isOwnedPost(post) else { return nil }
        
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completionHandler) in
            self?.viewModel.removePost(post, onComplete: { (error) in
                if let _error = error, let _self = self {
                    AlertHelper.showOKAlert(_error.title, message: nil, onController: _self, onHandleAction: nil, onComplete: nil)
                }
                self?.reloadData()
            })
            completionHandler(true)
        })

        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
}

extension HomeVC: RegisterOrLoginScreenProtocol {
    func loginScreenDidDismiss() {
        setupLeftBarButtonItems()
    }
}
