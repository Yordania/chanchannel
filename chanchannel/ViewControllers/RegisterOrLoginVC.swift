//
//  RegisterOrLoginVC.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

protocol RegisterOrLoginScreenProtocol: AnyObject {
    func loginScreenDidDismiss()
}

final class RegisterOrLoginVC: UITableViewController {
    
    enum ScreenType {
        case login
        case register
        
        var headerViewTitle: String? {
            switch self {
            case .login: return "Sign-in to\nChanchannel!"
            case .register: return "Welcome to\nChanchannel!"
            }
        }
        
        var primaryButtonTitle: String? {
            switch self {
            case .login: return "Sign-in"
            case .register: return "Register"
            }
        }
        
        var secondaryButtonTitle: String? {
            switch self {
            case .login: return "I don't have an account yet"
            case .register: return "Actually, I have an account"
            }
        }
    }
    
    enum Row: Int {
        case email = 0
        case password
        case name
        
        var title: String? {
            switch self {
            case .email: return "Email"
            case .password: return "Password"
            case .name: return "Your name"
            }
        }
        
        var placeholder: String? {
            switch self {
            case .email: return "e.g johndoe@mail.com"
            case .password: return "minimum 8 characters"
            case .name: return "e.g John Doe"
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .email: return .emailAddress
            default: return .default
            }
        }
    }
    
    private let viewModel: RegisterOrLoginViewModel
    private let screenType: ScreenType
    private lazy var rows: [Row] = {
        return screenType == .login ? [.email, .password] : [.email, .password, .name]
    }()
    weak var delegate: RegisterOrLoginScreenProtocol?
    
    init(viewModel: RegisterOrLoginViewModel, screenType: ScreenType) {
        self.viewModel = viewModel
        self.screenType = screenType
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
        
        let headerView = RegisterOrLoginHeaderView(frame: .zero)
        headerView.titleLabel.text = screenType.headerViewTitle
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame.size.height = 175
        
        let footerView = RegisterOrLoginFooterView(frame: .zero)
        tableView.tableFooterView = footerView
        tableView.tableFooterView?.frame.size.height = footerView.getViewHeight()
        footerView.primaryButton.setTitle(screenType.primaryButtonTitle, for: .normal)
        footerView.primaryButton.addTarget(self, action: #selector(primaryButtonDidTap), for: .touchUpInside)
        footerView.secondaryButton.setTitle(screenType.secondaryButtonTitle, for: .normal)
        footerView.secondaryButton.addTarget(self, action: #selector(secondaryButtonDidTap), for: .touchUpInside)
    }
    
    private func showAlert(with error: AccountError) {
        AlertHelper.showOKAlert(error.title, message: nil, onController: self, onHandleAction: nil, onComplete: nil)
    }
    
    @objc private func cancelButtonDidTap(_ sender: UIBarButtonItem) {
        dismissScreen()
    }
    
    @objc private func primaryButtonDidTap(_ sender: UIButton) {
        view.endEditing(true)
        
        switch screenType {
        case .login:
            viewModel.doLogin { [weak self] (error) in
                guard let _error = error else {
                    self?.dismissScreen()
                    return
                }
                
                self?.showAlert(with: _error)
            }
        case .register:
            viewModel.doRegister { [weak self] (error) in
                guard let _error = error else {
                    self?.dismissScreen()
                    return
                }
                
                self?.showAlert(with: _error)
            }
        }
    }
    
    @objc private func secondaryButtonDidTap(_ sender: UIButton) {
        switch screenType {
        case .login:
            let registerVC = RegisterOrLoginVC(viewModel: RegisterOrLoginViewModel(), screenType: .register)
            registerVC.delegate = self
            navigationController?.pushViewController(registerVC, animated: true)
        case .register:
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func dismissScreen() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.loginScreenDidDismiss()
        }
    }
    
}

extension RegisterOrLoginVC {
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
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.becomeFirstResponder()
    }
}

extension RegisterOrLoginVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let row = Row(rawValue: textField.tag) else { return }
        switch row {
        case .email:
            viewModel.email = textField.text ?? ""
        case .password:
            viewModel.password = textField.text ?? ""
        case .name:
            viewModel.name = textField.text ?? ""
        }
    }
}

extension RegisterOrLoginVC: RegisterOrLoginScreenProtocol {
    func loginScreenDidDismiss() {
        delegate?.loginScreenDidDismiss()
    }
}
