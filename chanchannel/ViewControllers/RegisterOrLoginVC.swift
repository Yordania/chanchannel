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
    private var isAlreadyTriedToSignIn: Bool = false
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
        isAlreadyTriedToSignIn = true
        view.endEditing(true)
        
        let invalidFields = rows.filter({ return !checkValidity(for: $0) })
        guard invalidFields.isEmpty else {
            tableView.reloadSections([0], with: .automatic)
            return
        }
        
        view.showLoaderView()
        let handler: ((AccountError?) -> ()) = { [weak self] (error) in
            self?.view.hideLoaderView()
            guard let _error = error else {
                self?.dismissScreen()
                return
            }
            
            self?.showAlert(with: _error)
        }
        
        switch screenType {
        case .login:
            viewModel.doLogin(onComplete: handler)
        case .register:
            viewModel.doRegister(onComplete: handler)
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
    
    private func checkValidity(for row: Row) -> Bool {
        guard isAlreadyTriedToSignIn else { return true }
        switch row {
        case .email:
            return viewModel.isValidEmail(viewModel.email)
        case .password:
            return viewModel.isValidPassword(viewModel.password)
        default:
            return viewModel.isValidName(viewModel.name)
        }
    }
    
    private func setErrorLabel(for row: Row, isValid: Bool, cell: TextInputCell) {
        switch row {
        case .email:
            cell.setInfoLabel(isValid ? "" : "Wrong email format", type: isValid ? .default : .error)
        case .password:
            cell.setInfoLabel(isValid ? "" : "Minimal password length is 8", type: isValid ? .default : .error)
        default:
            cell.setInfoLabel(isValid ? "" : "Name couldn't be empty", type: isValid ? .default : .error)
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
        
        cell.delegate = self
        
        if let row = rows[safe: indexPath.row] {
            cell.titleLabel.text = row.title
            cell.textInputView.autocapitalizationType = .none
            cell.textInputView.keyboardType = row.keyboardType
            cell.textInputView.isSecureTextEntry = row == .password
            cell.textInputView.placeholder = row.placeholder
            cell.textInputView.tag = row.rawValue
            
            let isValid = checkValidity(for: row)
            setErrorLabel(for: row, isValid: isValid, cell: cell)
            switch row {
            case .email:
                cell.textInputView.text = viewModel.email
            case .password:
                cell.textInputView.text = viewModel.password
            default:
                cell.textInputView.text = viewModel.name
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.becomeFirstResponder()
    }
}

extension RegisterOrLoginVC: TextInputCellDelegate {
    func textInputCell(_ cell: TextInputCell, textDidChangeFor textField: UITextField, text: String) {
        guard let row = Row(rawValue: textField.tag) else { return }
        switch row {
        case .email: viewModel.email = text
        case .password: viewModel.password = text
        case .name: viewModel.name = text
        }
        
        let isValid = checkValidity(for: row)
        if isAlreadyTriedToSignIn {
            setErrorLabel(for: row, isValid: isValid, cell: cell)
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension RegisterOrLoginVC: RegisterOrLoginScreenProtocol {
    func loginScreenDidDismiss() {
        delegate?.loginScreenDidDismiss()
    }
}
