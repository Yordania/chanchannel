//
//  TextInputCell.swift
//  chanchannel
//
//  Created by Odan on 20/8/20.
//  Copyright © 2020 Odan. All rights reserved.
//

import UIKit

protocol TextInputCellDelegate: AnyObject {
    func textInputCell(_ cell: TextInputCell, textDidChangeFor textField: UITextField, text: String)
}

final class TextInputCell: UITableViewCell {
    
    enum InfoType {
        case error
        case `default`
        
        var textColor: UIColor {
            switch self {
            case .error:
                return .red
            default:
                return .label
            }
        }
    }
    
    weak var delegate: TextInputCellDelegate?
    
    private let separatorHeight: CGFloat = 1/UIScreen.main.scale
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()
    
    private(set) lazy var textInputView: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textAlignment = .right
        return textField
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.appColor(.separator)
        return view
    }()
    
    override func becomeFirstResponder() -> Bool {
        textInputView.becomeFirstResponder()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupComponents() {
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(textInputView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.layout(visualFormats: ["H:|-[titleLabel]-[textInputView]-|",
                                                  "H:|-[separatorView]|",
                                                  "H:|-[infoLabel]-|",
                                                  "V:|-[textInputView]-[separatorView(separatorHeight)]-[infoLabel]-|"],
                                  metrics: ["separatorHeight" : separatorHeight],
                                  views: ["titleLabel" : titleLabel,
                                          "textInputView" : textInputView,
                                          "infoLabel" : infoLabel,
                                          "separatorView" : separatorView])
        
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.3).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: textInputView.centerYAnchor).isActive = true
        
        textInputView.delegate = self
    }
    
    func setInfoLabel(_ title: String, type: InfoType) {
        infoLabel.text = title
        infoLabel.textColor = type.textColor
    }
    
}

extension TextInputCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange, with: string)
            delegate?.textInputCell(self, textDidChangeFor: textField, text: updatedText)
        }
        return true
    }
    
}
