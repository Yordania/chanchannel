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
        viewModel.fetchData() { [weak self] in
            self?.tableView.reloadData()
            onComplete?()
        }
    }
    
    @objc private func pullToRefreshDidInitate(_ sender: UIRefreshControl) {
        reloadData {
            sender.endRefreshing()
        }
    }
    
    @objc private func addButtonDidTap(_ sender: UIBarButtonItem) {
        guard viewModel.isUserAlreadyLogin else {
            if let loginVC = viewModel.getLoginScreen() {
                loginVC.delegate = self
                let navCont = UINavigationController(rootViewController: loginVC)
                present(navCont, animated: true, completion: nil)
            }
            return
        }
        let vc = CreatePostVC(viewModel: CreatePostViewModel())
        let navCont = UINavigationController(rootViewController: vc)
        navigationController?.present(navCont, animated: true, completion: nil)
    }
    
    @objc private func logoutButtonDidTap(_ sender: UIBarButtonItem) {
        do {
            try viewModel.logout()
            navigationItem.leftBarButtonItem = nil
        } catch {
            let alert = UIAlertController(title: "SignOut failed", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
}

extension HomeVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let _cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = _cell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell.textLabel?.numberOfLines = 5
        if let post = viewModel.posts[safe: indexPath.row] {
            cell.textLabel?.text = post.body
            cell.detailTextLabel?.text = post.author
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
