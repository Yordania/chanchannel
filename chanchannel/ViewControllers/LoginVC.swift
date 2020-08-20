//
//  LoginVC.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

protocol LoginScreenProtocol: AnyObject {
    func loginScreenDidDismiss()
}

final class LoginVC: UITableViewController {
    
    enum Row: Int {
        case email = 0
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
    
    private let viewModel: LoginViewModel
    private let rows: [Row] = [.email, .password]
    weak var delegate: LoginScreenProtocol?
    
    init(viewModel: LoginViewModel) {
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
    
    private func setupComponents() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTap))
        
        tableView.separatorStyle = .none
        tableView.register(TextInputCell.self, forCellReuseIdentifier: "TextInput")
        
        let headerView = LoginHeaderView(frame: .zero)
        headerView.titleLabel.text = "Sign-in to\nChanchannel!"
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame.size.height = 175
        
        let footerView = LoginFooterView(frame: .zero)
        tableView.tableFooterView = footerView
        tableView.tableFooterView?.frame.size.height = footerView.getViewHeight()
        footerView.loginButton.addTarget(self, action: #selector(loginButtonDidTap), for: .touchUpInside)
        footerView.registerButton.addTarget(self, action: #selector(registerButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func cancelButtonDidTap(_ sender: UIBarButtonItem) {
        dismissScreen()
    }
    
    @objc private func loginButtonDidTap(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.doLogin { [weak self] (error) in
            guard let _error = error else {
                self?.dismissScreen()
                return
            }
            
            let alert = UIAlertController(title: _error.title, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func registerButtonDidTap(_ sender: UIButton) {
        let navCont = UINavigationController(rootViewController: LoginVC(viewModel: LoginViewModel()))
        present(navCont, animated: true, completion: nil)
    }
    
    private func dismissScreen() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.loginScreenDidDismiss()
        }
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
            cell.textInputView.autocapitalizationType = .none
            cell.textInputView.keyboardType = row.keyboardType
            cell.textInputView.isSecureTextEntry = row == .password
            cell.textInputView.placeholder = row.placeholder
            cell.textInputView.delegate = self
            cell.textInputView.tag = row.rawValue
            cell.setInfoLabel(indexPath.description, type: .error)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.becomeFirstResponder()
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let row = Row(rawValue: textField.tag) else { return }
        switch row {
        case .email:
            viewModel.email = textField.text ?? ""
        case .password:
            viewModel.password = textField.text ?? ""
        }
    }
}
