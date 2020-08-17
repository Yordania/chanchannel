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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidTap))
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Reloading")
        refreshControl?.addTarget(self, action: #selector(pullToRefreshDidInitate), for: .valueChanged)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        viewModel.fetchData() { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc private func pullToRefreshDidInitate(_ sender: UIRefreshControl) {
        viewModel.fetchData() { [weak self] in
            self?.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
    @objc private func addButtonDidTap(_ sender: UIBarButtonItem) {
        let date = Date()
        let post = Post(id: UUID().uuidString, body: "\(date.timeIntervalSince1970)", userId: nil, likes: 0, createdAt: Timestamp(date: date), updatedAt: Timestamp(date: date))
        viewModel.addData(post)
    }
    
}

extension HomeVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.posts[indexPath.row].body
        return cell
    }
}
