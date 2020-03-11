//
//  DATextBox.swift
//  DigiByte
//
//  Created by Yoshi Jaeger on 06.12.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

class DATextBox: UIView {
    enum TextBoxMode {
        case any
        case numbersOnly
    }
    private static let contentColor = UIColor(red: 67 / 255, green: 68 / 255, blue: 90 / 255, alpha: 1.0)
    
    private let showPasteButton: Bool
    private let showClearButton: Bool
    private let mode: TextBoxMode
    
    var clipboardButtonTapped: (() -> Void)? = nil
    var clearButtonTapped: (() -> Void)? = nil
    
    var textChanged: ((String) -> Void)? = nil
    var copyMode: Bool = false
    
    var placeholder: String = "" {
        didSet {
            updatePlacehodler()
        }
    }
    
    let clipboardButton = UIButton()
    let asteriskButton = UIButton()
    let textBox = UITextField()
    
    let stackView = UIStackView()
    
    init(showClearButton: Bool = false, showPasteButton: Bool = false, mode: TextBoxMode = .any) {
        self.showPasteButton = showPasteButton
        self.showClearButton = showClearButton
        self.mode = mode
        super.init(frame: .zero)
        
        addSubviews()
        addConstraints()
        addEvents()
        
        setStyle()
    }
    
    private func addSubviews() {
        addSubview(stackView)
        
        if showClearButton { stackView.addArrangedSubview(asteriskButton) }
        stackView.addArrangedSubview(textBox)
        if showPasteButton { stackView.addArrangedSubview(clipboardButton) }
    }
    
    private func addConstraints() {
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        stackView.constrain(toSuperviewEdges: nil)
    }
    
    @objc
    private func clipboardButtonTappedInternal() {
        if let callback = clipboardButtonTapped {
            callback()
            return
        }
        
        let cb = UIPasteboard.general
        
        if copyMode, let t = textBox.text {
            cb.string = t
        } else {
            textBox.text = cb.string
        }
    }
    
    @objc
    private func clearButtonTappedInternal() {
        if let callback = clearButtonTapped {
            callback()
            return
        }
        
        textBox.text = ""
    }
    
    private func addEvents() {
        clipboardButton.addTarget(self, action: #selector(clipboardButtonTappedInternal), for: .touchUpInside)
        asteriskButton.addTarget(self, action: #selector(clearButtonTappedInternal), for: .touchUpInside)
        textBox.delegate = self
    }
    
    private func setStyle() {
        layer.cornerRadius = 6
        layer.masksToBounds = true
        backgroundColor = .clear
        
        layer.borderWidth = 2
        layer.borderColor = DATextBox.contentColor.cgColor // 67 68 90
        
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .horizontal
        
        asteriskButton.setImage(UIImage(named: "da_asterisk"), for: .normal)
        asteriskButton.backgroundColor = DATextBox.contentColor
        asteriskButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        
        clipboardButton.setImage(UIImage(named: "da_clipboard")?.withRenderingMode(.alwaysTemplate), for: .normal)
        clipboardButton.backgroundColor = DATextBox.contentColor
        clipboardButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        clipboardButton.tintColor = .white
        
        textBox.backgroundColor = .clear
        textBox.font = UIFont.da.customBold(size: 14)
        textBox.textColor = .white

        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        textBox.leftView = paddingView
        textBox.leftViewMode = .always
        textBox.autocorrectionType = .no
        textBox.autocapitalizationType = .none
        textBox.keyboardAppearance = .dark
        textBox.returnKeyType = .done
        
        switch mode {
            case .numbersOnly:
                let tb = UIToolbar()
                tb.barStyle = .blackTranslucent
                tb.items = [
                    UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil),
                    UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(hideKeyboard))
                ]
                tb.sizeToFit()
                textBox.keyboardType = .numberPad
                textBox.inputAccessoryView = tb
            
            default:
                textBox.keyboardType = .asciiCapable
        }
    }
    
    @objc
    private func hideKeyboard() {
        textBox.resignFirstResponder()
    }
    
    private func updatePlacehodler() {
        textBox.attributedPlaceholder = NSAttributedString(string: placeholder.uppercased(), attributes: [
            NSAttributedString.Key.foregroundColor: DATextBox.contentColor,
            NSAttributedString.Key.font: UIFont.da.customBold(size: 14),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DATextBox: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Reject alphabetic chars if mode is numbers-only
        if mode == .numbersOnly, string != "" {
            if Int(string) == nil { return false }
        }
        
        // Notify parent on changed text
        if let cb = self.textChanged, let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            cb(txtAfterUpdate)
        }
        
        return true
    }
}
