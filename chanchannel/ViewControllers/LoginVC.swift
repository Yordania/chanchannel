//
//  LoginVC.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class LoginVC: UITableViewController {
    
    enum Row {
        case email
        case password
        
        var title: String? {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            }
        }
        
        var placeholder: String? {
            switch self {
            case .email:
                return "e.g johndoe@mail.com"
            case .password:
                return "minimum 8 characters"
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            default:
                return .default
            }
        }
    }
    
    private let rows: [Row] = [.email, .password]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
    }
    
    private func setupComponents() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTap))
        
        let headerView = LoginHeaderView(frame: .zero)
        headerView.titleLabel.text = "Sign-in to\nChanchannel!"
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame.size.height = 175
        tableView.register(TextInputCell.self, forCellReuseIdentifier: "TextInput")
    }
    
    @objc private func cancelButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LoginVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextInput", for: indexPath) as? TextInputCell else {
            return UITableViewCell()
        }
        
        if let row = rows[safe: indexPath.row] {
            cell.titleLabel.text = row.title
            cell.textInputView.keyboardType = row.keyboardType
            cell.textInputView.placeholder = row.placeholder
            cell.setInfoLabel(indexPath.description, type: .error)
        }
        
        return cell
    }
}
