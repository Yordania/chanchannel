//
//  CreatePostVC.swift
//  chanchannel
//
//  Created by Odan on 17/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class CreatePostVC: UITableViewController {
    
    private let viewModel: CreatePostViewModel
    
    init(viewModel: CreatePostViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
    }
    
    private func setupComponents() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(postButtonDidTap))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTap))
        tableView.register(ComposePostCell.self, forCellReuseIdentifier: "ComposePostCell")
    }
    
    @objc private func postButtonDidTap(_ sender: UIBarButtonItem) {
        viewModel.addData { [weak self] (error) in
            guard let _error = error else {
                self?.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
            
            if let _self = self {
                AlertHelper.showOKAlert(_error.title, message: nil, onController: _self, onHandleAction: nil, onComplete: nil)
            }
        }
    }
    
    @objc private func cancelButtonDidTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension CreatePostVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ComposePostCell", for: indexPath) as? ComposePostCell else {
            return UITableViewCell()
        }
        cell.textView.delegate = self
        return cell
    }
}

extension CreatePostVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.post.body = textView.text
    }
}
