//
//  LoginVC.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

final class LoginVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
    }
    
    private func setupComponents() {
        tableView.separatorStyle = .none
        tableView.tableHeaderView = LoginHeaderView(frame: .zero)
        tableView.tableHeaderView?.frame.size.height = 200
    }
    
}

extension LoginVC {
    
}
