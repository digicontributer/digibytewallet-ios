//
//  AmountViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-05-19.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

private let currencyHeight: CGFloat = 80.0
private let feeHeight: CGFloat = 130.0

class AmountViewController : UIViewController {

    init(store: Store, isPinPadExpandedAtLaunch: Bool, isRequesting: Bool = false) {
        self.store = store
        self.isPinPadExpandedAtLaunch = isPinPadExpandedAtLaunch
        self.isRequesting = isRequesting
        self.currencySlider = CurrencySlider(rates: store.state.rates,
                                             defaultCode: store.state.defaultCurrencyCode,
                                             isBtcSwapped: store.state.isBtcSwapped)
        self.currencyToggle = ShadowButton(title: S.Symbols.currencyButtonTitle(maxDigits: store.state.maxDigits), type: .tertiary)
        self.feeSelector = FeeSelector(store: store)
        self.pinPad = PinPadViewController(style: .white, keyboardType: .decimalPad, maxDigits: store.state.maxDigits)
        super.init(nibName: nil, bundle: nil)
    }

    var balanceTextForAmount: ((Satoshis?, Rate?) -> (NSAttributedString?, NSAttributedString?)?)?
    var didUpdateAmount: ((Satoshis?) -> Void)?
    var didChangeFirstResponder: ((Bool) -> Void)?

    var currentOutput: String {
        return amountLabel.text ?? ""
    }
    var selectedRate: Rate? {
        didSet {
            fullRefresh()
        }
    }
    var didUpdateFee: ((Fee) -> Void)? {
        didSet {
            feeSelector.didUpdateFee = didUpdateFee
        }
    }
    func forceUpdateAmount(amount: Satoshis) {
        self.amount = amount
        fullRefresh()
    }

    func expandPinPad() {
        if pinPadHeight?.constant == 0.0 {
            togglePinPad()
        }
    }

    private let store: Store
    private let isPinPadExpandedAtLaunch: Bool
    private let isRequesting: Bool
    var minimumFractionDigits = 0
    private var hasTrailingDecimal = false
    private var pinPadHeight: NSLayoutConstraint?
    private var currencyContainerHeight: NSLayoutConstraint?
    private var currencyContainterTop: NSLayoutConstraint?
    private var feeSelectorHeight: NSLayoutConstraint?
    private var feeSelectorTop: NSLayoutConstraint?
    private let placeholder = UILabel(font: .customBody(size: 16.0), color: .grayTextTint)
    private let amountLabel = UILabel(font: .customBody(size: 26.0), color: .darkText)
    private let pinPad: PinPadViewController
    private let currencyToggle: ShadowButton
    private let border = UIView(color: .secondaryShadow)
    private let bottomBorder = UIView(color: .secondaryShadow)
    private let cursor = BlinkingView(blinkColor: C.defaultTintColor)
    private let balanceLabel = UILabel()
    private let feeLabel = UILabel()
    private let currencyContainer = InViewAlert(type: .secondary)
    private let feeContainer = InViewAlert(type: .secondary)
    private let tapView = UIView()
    private let currencySlider: CurrencySlider
    private let editFee = UIButton(type: .system)
    private let feeSelector: FeeSelector

    private var amount: Satoshis? {
        didSet {
            updateAmountLabel()
            updateBalanceLabel()
            didUpdateAmount?(amount)
        }
    }

    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        setInitialData()
    }

    private func addSubviews() {
        view.addSubview(amountLabel)
        view.addSubview(placeholder)
        view.addSubview(currencyToggle)
        view.addSubview(currencyContainer)
        view.addSubview(feeContainer)
        view.addSubview(border)
        view.addSubview(cursor)
        view.addSubview(balanceLabel)
        view.addSubview(feeLabel)
        view.addSubview(tapView)
        view.addSubview(bottomBorder)
        view.addSubview(editFee)
    }

    private func addConstraints() {
        amountLabel.constrain([
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            amountLabel.centerYAnchor.constraint(equalTo: currencyToggle.centerYAnchor) ])
        placeholder.constrain([
            placeholder.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: 2.0),
            placeholder.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor) ])
        cursor.constrain([
            cursor.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 2.0),
            cursor.heightAnchor.constraint(equalToConstant: 24.0),
            cursor.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            cursor.widthAnchor.constraint(equalToConstant: 2.0) ])
        currencyToggle.constrain([
            currencyToggle.topAnchor.constraint(equalTo: view.topAnchor, constant: C.padding[2]),
            currencyToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]) ])
        currencyContainerHeight = currencyContainer.constraint(.height, constant: 0.0)
        if isRequesting {
            currencyContainterTop = currencyContainer.constraint(toBottom: currencyToggle, constant: C.padding[2])
        } else {
            currencyContainterTop = currencyContainer.constraint(toBottom: feeLabel, constant: C.padding[2])
        }
        currencyContainer.constrain([
            currencyContainterTop,
            currencyContainer.constraint(.leading, toView: view),
            currencyContainer.constraint(.trailing, toView: view),
            currencyContainerHeight ])
        currencyContainer.arrowXLocation = view.bounds.width - 30.0 - C.padding[2]

        feeSelectorHeight = feeContainer.heightAnchor.constraint(equalToConstant: 0.0)
        feeSelectorTop = feeContainer.topAnchor.constraint(equalTo: currencyContainer.bottomAnchor, constant: 0.0)
        feeContainer.constrain([
            feeSelectorTop,
            feeSelectorHeight,
            feeContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feeContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        feeContainer.arrowXLocation = C.padding[4]

        border.constrain([
            border.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            border.topAnchor.constraint(equalTo: feeContainer.bottomAnchor),
            border.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1.0) ])
        balanceLabel.constrain([
            balanceLabel.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),
            balanceLabel.topAnchor.constraint(equalTo: cursor.bottomAnchor) ])
        feeLabel.constrain([
            feeLabel.leadingAnchor.constraint(equalTo: balanceLabel.leadingAnchor),
            feeLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor) ])
        pinPadHeight = pinPad.view.heightAnchor.constraint(equalToConstant: 0.0)
        addChildViewController(pinPad, layout: {
            pinPad.view.constrain([
                pinPad.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pinPad.view.topAnchor.constraint(equalTo: border.bottomAnchor),
                pinPad.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pinPad.view.bottomAnchor.constraint(equalTo: bottomBorder.topAnchor),
                pinPadHeight ])
        })
        editFee.constrain([
            editFee.leadingAnchor.constraint(equalTo: feeLabel.trailingAnchor, constant: -8.0),
            editFee.centerYAnchor.constraint(equalTo: feeLabel.centerYAnchor, constant: -1.0),
            editFee.widthAnchor.constraint(equalToConstant: 44.0),
            editFee.heightAnchor.constraint(equalToConstant: 44.0) ])
        bottomBorder.constrain([
            bottomBorder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: 1.0) ])
        tapView.constrain([
            tapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tapView.topAnchor.constraint(equalTo: view.topAnchor),
            tapView.trailingAnchor.constraint(equalTo: currencyToggle.leadingAnchor, constant: 4.0),
            tapView.bottomAnchor.constraint(equalTo: currencyContainer.topAnchor) ])
        preventAmountOverflow()
    }

    private func setInitialData() {
        cursor.isHidden = true
        cursor.startBlinking()
        amountLabel.text = ""
        placeholder.text = S.Send.amountLabel
        currencySlider.load()
        currencyContainer.contentView = currencySlider
        currencyToggle.isToggleable = true
        bottomBorder.isHidden = true
        if store.state.isBtcSwapped {
            if let rate = store.state.currentRate {
                selectedRate = rate
            }
        }
        pinPad.ouputDidUpdate = { [weak self] output in
            self?.handlePinPadUpdate(output: output)
        }
        currencySlider.didSelectCurrency = { [weak self] rate in
            self?.selectedRate = rate.code == C.btcCurrencyCode ? nil : rate
            self?.toggleCurrencyContainer()
        }
        currencyToggle.tap = { [weak self] in
            self?.toggleCurrencyContainer()
        }
        let gr = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapView.addGestureRecognizer(gr)
        tapView.isUserInteractionEnabled = true

        if isPinPadExpandedAtLaunch {
            didTap()
        }

        feeContainer.contentView = feeSelector
        editFee.tap = { [weak self] in
            self?.toggleFeeSelector()
        }
        editFee.setImage(#imageLiteral(resourceName: "Edit"), for: .normal)
        editFee.imageEdgeInsets = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)
        editFee.tintColor = .grayTextTint
        editFee.isHidden = true
    }

    private func preventAmountOverflow() {
        amountLabel.constrain([
            amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: currencyToggle.leadingAnchor, constant: -C.padding[2]) ])
        amountLabel.minimumScaleFactor = 0.5
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
    }

    private func handlePinPadUpdate(output: String) {
        placeholder.isHidden = output.utf8.count > 0 ? true : false
        minimumFractionDigits = 0 //set default
        if let decimalLocation = output.range(of: NumberFormatter().currencyDecimalSeparator)?.upperBound {
            let locationValue = output.distance(from: output.endIndex, to: decimalLocation)
            minimumFractionDigits = abs(locationValue)
        }

        //If trailing decimal, append the decimal to the output
        hasTrailingDecimal = false //set default
        if let decimalLocation = output.range(of: NumberFormatter().currencyDecimalSeparator)?.upperBound {
            if output.endIndex == decimalLocation {
                hasTrailingDecimal = true
            }
        }

        var newAmount: Satoshis?
        if let rate = selectedRate {
            if let value = Double(output) {
                newAmount = Satoshis(value: value, rate: rate)
            }
        } else {
            if store.state.maxDigits == 2 {
                if let bits = Bits(string: output) {
                    newAmount = Satoshis(bits: bits)
                }
            } else {
                if let bitcoin = Bitcoin(string: output) {
                    newAmount = Satoshis(bitcoin: bitcoin)
                }
            }
        }

        if let newAmount = newAmount {
            if newAmount > C.maxMoney {
                pinPad.removeLast()
            } else {
                amount = newAmount
            }
        } else {
            amount = nil
        }
    }

    private func updateAmountLabel() {
        guard let amount = amount else { amountLabel.text = ""; return }
        let displayAmount = DisplayAmount(amount: amount, state: store.state, selectedRate: selectedRate, minimumFractionDigits: minimumFractionDigits)
        var output = displayAmount.description
        if hasTrailingDecimal {
            output = output.appending(NumberFormatter().currencyDecimalSeparator)
        }
        amountLabel.text = output
        placeholder.isHidden = output.utf8.count > 0 ? true : false
    }

    func updateBalanceLabel() {
        if let (balance, fee) = balanceTextForAmount?(amount, selectedRate) {
            balanceLabel.attributedText = balance
            feeLabel.attributedText = fee
            if let amount = amount, amount > 0, !isRequesting {
                editFee.isHidden = false
            } else {
                editFee.isHidden = true
            }
        }
    }

    @objc private func toggleCurrencyContainer() {
        let isCurrencySwitcherCollapsed: Bool = currencyContainerHeight?.constant == 0.0
        UIView.spring(C.animationDuration, animations: {
            if isCurrencySwitcherCollapsed {
                if let height = self.feeSelectorHeight, !height.isActive {
                    self.feeSelector.removeIntrinsicSize()
                    NSLayoutConstraint.activate([height])
                }
                self.currencyContainerHeight?.constant = currencyHeight
                if !self.isRequesting {
                    self.currencyContainterTop?.constant = 0.0
                }
            } else {
                self.currencyContainerHeight?.constant = 0.0
                if !self.isRequesting {
                    self.currencyContainterTop?.constant = C.padding[2]
                }
            }
            self.parent?.parent?.view?.layoutIfNeeded()
        }, completion: {_ in })
    }

    private func toggleFeeSelector() {
        guard let height = feeSelectorHeight else { return }
        let isCollapsed: Bool = height.isActive
        UIView.spring(C.animationDuration, animations: {
            if isCollapsed {
                if self.currencyContainerHeight?.constant != 0.0 {
                    self.currencyContainerHeight?.constant = 0.0
                }
                NSLayoutConstraint.deactivate([height])
                self.feeSelector.addIntrinsicSize()
                self.currencyContainterTop?.constant = 0.0
            } else {
                self.feeSelector.removeIntrinsicSize()
                NSLayoutConstraint.activate([height])
            }
            self.parent?.parent?.view?.layoutIfNeeded()
        }, completion: {_ in })
    }

    @objc private func didTap() {
        UIView.spring(C.animationDuration, animations: {
            self.togglePinPad()
            self.parent?.parent?.view.layoutIfNeeded()
        }, completion: { completed in })
    }

    func closePinPad() {
        pinPadHeight?.constant = 0.0
        cursor.isHidden = true
        bottomBorder.isHidden = true
        updateBalanceAndFeeLabels()
        updateBalanceLabel()
    }

    private func togglePinPad() {
        let isCollapsed: Bool = pinPadHeight?.constant == 0.0
        pinPadHeight?.constant = isCollapsed ? pinPad.height : 0.0
        cursor.isHidden = isCollapsed ? false : true
        bottomBorder.isHidden = isCollapsed ? false : true
        updateBalanceAndFeeLabels()
        updateBalanceLabel()
        didChangeFirstResponder?(isCollapsed)
    }

    private func updateBalanceAndFeeLabels() {
        if let amount = amount, amount.rawValue > 0 {
            balanceLabel.isHidden = false
            if !isRequesting {
                editFee.isHidden = false
            }
        } else {
            balanceLabel.isHidden = cursor.isHidden
            if !isRequesting {
                editFee.isHidden = true
            }
        }
    }

    private func fullRefresh() {
        if let rate = selectedRate {
            currencyToggle.title = "\(rate.code) (\(rate.currencySymbol))"
        } else {
            currencyToggle.title = S.Symbols.currencyButtonTitle(maxDigits: store.state.maxDigits)
        }
        updateBalanceLabel()
        updateAmountLabel()

        //Update pinpad content to match currency change
        //This must be done AFTER the amount label has updated
        let currentOutput = amountLabel.text ?? ""
        var set = CharacterSet.decimalDigits
        set.formUnion(CharacterSet(charactersIn: NumberFormatter().currencyDecimalSeparator))
        pinPad.currentOutput = String(String.UnicodeScalarView(currentOutput.unicodeScalars.filter { set.contains($0) }))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Fees : Equatable {}

func ==(lhs: Fees, rhs: Fees) -> Bool {
    return lhs.regular == rhs.regular && lhs.economy == rhs.economy
}
