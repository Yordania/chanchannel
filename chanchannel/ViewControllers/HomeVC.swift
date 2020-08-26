//
//  HomeVC.swift
//  chanchannel
//
//  Created by Odan on 14/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit
import SkeletonView

final class HomeVC: UITableViewController {
    
    private let viewModel: HomeViewModel
    private var isFirstTimeLoad: Bool = true
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLoginStatus()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isFirstTimeLoad {
            tableView.showAnimatedGradientSkeleton()
            tableView.isUserInteractionEnabled = false
        }
    }
    
    private func setupComponents() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidTap))
        
        tableView.isSkeletonable = true
        tableView.separatorStyle = .none
        tableView.register(TimelinePostCell.self, forCellReuseIdentifier: "postCell")
        tableView.register(TimelinePostCell.self, forCellReuseIdentifier: "postCellSkeleton")
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Reloading")
        refreshControl?.addTarget(self, action: #selector(pullToRefreshDidInitate), for: .valueChanged)
    }
    
    private func setupLoginStatus() {
        if viewModel.isUserAlreadyLogin {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "SignOut", style: .done, target: self, action: #selector(logoutButtonDidTap))
            if let name = viewModel.userDisplayName {
                title = "Hi \(name)!"
            }
        } else {
            title = "ChanChannel"
        }
    }
    
    private func reloadData(_ onComplete: (() -> ())? = nil) {
        viewModel.fetchData() { [weak self] error in
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
            self?.setupLoginStatus()
            if let _error = error, let _self = self {
                AlertHelper.showOKAlert(_error.title, message: nil, onController: _self, onHandleAction: nil, onComplete: nil)
            } else {
                self?.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
}

extension HomeVC {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFirstTimeLoad ? 15 : viewModel.posts.count
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
        if let post = viewModel.posts[safe: indexPath.row] {
            cell.postLabelView.text = post.body
            let authorColor = viewModel.authorColors.first(where: { return $0.id == post.userId })?.color
            cell.setAuthor(post.author, color: authorColor)
            cell.dateLabelView.text = dateFormatter.string(from: post.createdAt.dateValue())
            cell.separatorView.isHidden = indexPath.row == (viewModel.posts.count - 1)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let post = viewModel.posts[safe: indexPath.row] else { return }
        let authorColor = viewModel.authorColors.first(where: { return $0.id == post.userId })?.color
        let postDetailVC = PostDetailVC(viewModel: PostDetailViewModel(postId: post.id ?? ""), authorColor: authorColor)
        postDetailVC.delegate = self
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let post = viewModel.posts[safe: indexPath.row],
            viewModel.isOwnedPost(post) else { return nil }
        
        let cell = tableView.cellForRow(at: indexPath)
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completionHandler) in
            cell?.contentView.showLoaderView()
            self?.viewModel.removePost(post, onComplete: { (error) in
                cell?.contentView.hideLoaderView {
                    if let _error = error, let _self = self {
                        AlertHelper.showOKAlert(_error.title, message: nil, onController: _self, onHandleAction: nil, onComplete: nil)
                    } else {
                        tableView.beginUpdates()
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        tableView.endUpdates()
                    }
                }
            })
            completionHandler(true)
        })

        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isFirstTimeLoad, indexPath.row == viewModel.posts.count - 1 else { return }
        viewModel.fetchPaginationData { [weak self] (error) in
            self?.tableView.reloadData()
            if let _error = error, let _self = self {
                AlertHelper.showOKAlert(_error.title, message: _error.message, onController: _self, onHandleAction: nil, onComplete: nil)
            }
        }
    }
    
}

extension HomeVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "postCellSkeleton"
    }
}

extension HomeVC: RegisterOrLoginScreenDelegate {
    func loginScreenDidDismiss() {
        setupLoginStatus()
    }
}

extension HomeVC: PostDetailScreenDelegate {
    func postDetailScreenDidRemovePost() {
        reloadData()
    }
}
