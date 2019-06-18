//
//  DGBTodayViewController.swift
//  DigiByte Today Extension
//
//  Created by Yoshi Jäger on 28.04.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit
import NotificationCenter

let APP_GROUP_ID                  = "group.org.digibytefoundation.DigiByte"
let APP_GROUP_REQUEST_DATA_KEY    = "kBRSharedContainerDataWalletRequestDataKey"
let APP_GROUP_RECEIVE_ADDRESS_KEY = "kBRSharedContainerDataWalletReceiveAddressKey"

let SEND_URL = "digibytewallet://x-callback-url/send"
let SCAN_URL = "digibytewallet://x-callback-url/scanqr" // obsolete
let RECEIVE_URL = "digibytewallet://x-callback-url/receive"
let CONTACTS_URL = "digibytewallet://x-callback-url/contacts"
let DIGIID_URL = "digibytewallet://x-callback-url/digi-id"

let QRImageHeight: CGFloat = 200.0
let padding: CGFloat = 10.0

fileprivate class ActionButton: UIButton {
    var callback: (() -> Void)? = nil
}

fileprivate class SuccessMessage: UIView {
    let containerView = UIView()
    let label = UILabel()
    
    init(message: String) {
        super.init(frame: .zero)
        
        self.addSubview(containerView)
        containerView.addSubview(label)
        
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.text = message
        label.textAlignment = .center
        
        containerView.backgroundColor = UIColor(red: 0x02 / 255, green: 0x5D / 255, blue: 0xBA / 255, alpha: 1.0)
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func show(above: UIView) {
        let view = self
        above.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: above.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: above.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: above.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: above.bottomAnchor).isActive = true
        
        view.layoutIfNeeded()
        
        if #available(iOSApplicationExtension 10.0, *) {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
        
        UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
            view.alpha = 0.0
        }, completion: nil)
    }
}

class DGBTodayViewController: UIViewController, NCWidgetProviding {
    var mainView: UIView!
    
    lazy var app: UserDefaults = {
        return UserDefaults(suiteName: APP_GROUP_ID)!
    }()
    
    var qrImage = UIImageView()
    var receiveHeaderLabel = UILabel()
    var receiveAddressLabel = UILabel()
    var actionItemHeader = UILabel()
    
    var actionItemView = UIStackView()
    
    var qrImageConstraint: NSLayoutConstraint!
    var receiveHeaderLabelConstraint: NSLayoutConstraint!
    var actionLabelConstraint: NSLayoutConstraint!
    
    var actionItemsCenter: NSLayoutConstraint!
    var actionItemsLeft: NSLayoutConstraint!
    
    var digiIDBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        addConstraints()
        setStyle()
        setContent()
        addEvents()
    }
    
    func createActionButtonItem(_ title: String, image: UIImage?, _ tint: Bool = false, callback: @escaping (() -> Void)) -> UIButton {
        let btn = ActionButton()
//        btn.setTitle(title, for: .normal)
        btn.setImage(tint ? image?.withRenderingMode(.alwaysTemplate) : image?.withRenderingMode(.alwaysOriginal), for: .normal)
        if tint {
            btn.tintColor = UIColor.white
        }
        
        let c1 = btn.widthAnchor.constraint(equalToConstant: 32)
        c1.priority = UILayoutPriority(999)
        c1.isActive = true
        
        let c2 = btn.heightAnchor.constraint(equalToConstant: 32)
        c2.priority = UILayoutPriority(999)
        c2.isActive = true
        
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentMode = .scaleAspectFit
        
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        btn.callback = { [weak btn] in
            if #available(iOSApplicationExtension 10.0, *) {
                let feedback = UISelectionFeedbackGenerator()
                feedback.prepare()
                feedback.selectionChanged()
            }
            callback()
        }
        
        return btn
    }
    
    @objc
    private func buttonTapped(_ sender: UIButton) {
        let btn = sender as! ActionButton
        btn.callback?()
    }
    
    private func addSubviews() {
        view.backgroundColor = .clear
        mainView = view
        mainView!.backgroundColor = .clear
        
        mainView.addSubview(qrImage)
        
        mainView.addSubview(receiveHeaderLabel)
        mainView.addSubview(receiveAddressLabel)
        
        mainView.addSubview(actionItemHeader)
        
        mainView.addSubview(actionItemView)
        
        actionItemView.addArrangedSubview(createActionButtonItem("Send", image: UIImage(named: "sendArrow"), callback: {
            self.extensionContext?.open(URL(string: SEND_URL)!, completionHandler: nil)
        }))
        actionItemView.addArrangedSubview(createActionButtonItem("Receive", image: UIImage(named: "receiveArrow"), callback: {
            self.extensionContext?.open(URL(string: RECEIVE_URL)!, completionHandler: nil)
        }))
        actionItemView.addArrangedSubview(createActionButtonItem("Contacts", image: UIImage(named: "AddressBook"), callback: {
            self.extensionContext?.open(URL(string: CONTACTS_URL)!, completionHandler: nil)
        }))
        
        digiIDBtn = createActionButtonItem("Digi-ID", image: UIImage(named: "Digi-id-icon"), true, callback: {
            self.extensionContext?.open(URL(string: DIGIID_URL)!, completionHandler: nil)
        })
        
        mainView.addSubview(digiIDBtn)
        //        actionItemView.addArrangedSubview(UIView())
    }
    
    private func addConstraints() {
        var c0 = [NSLayoutConstraint]()
        qrImage.translatesAutoresizingMaskIntoConstraints = false
        qrImageConstraint = qrImage.heightAnchor.constraint(equalToConstant: QRImageHeight)
        c0.append(qrImage.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10))
        c0.append(qrImage.centerXAnchor.constraint(equalTo: mainView.centerXAnchor))
        c0.append(qrImage.widthAnchor.constraint(equalToConstant: QRImageHeight))
        c0.append(qrImageConstraint)
        
        var c1 = [NSLayoutConstraint]()
        receiveHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        receiveHeaderLabelConstraint = receiveHeaderLabel.topAnchor.constraint(equalTo: qrImage.bottomAnchor, constant: padding)
        c1.append(receiveHeaderLabel.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: padding))
        c1.append(receiveHeaderLabel.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -padding))
        c1.append(receiveHeaderLabelConstraint)
        
        var c2 = [NSLayoutConstraint]()
        receiveAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        c2.append(receiveAddressLabel.topAnchor.constraint(equalTo: receiveHeaderLabel.bottomAnchor, constant: 5))
        c2.append(receiveAddressLabel.leftAnchor.constraint(equalTo: receiveHeaderLabel.leftAnchor))
        c2.append(receiveAddressLabel.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -padding))
        
        var c3 = [NSLayoutConstraint]()
        actionItemHeader.translatesAutoresizingMaskIntoConstraints = false
        actionLabelConstraint = actionItemHeader.topAnchor.constraint(equalTo: receiveAddressLabel.bottomAnchor, constant: padding)
        c3.append(actionItemHeader.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: padding))
        c3.append(actionItemHeader.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -padding))
        c3.append(actionLabelConstraint)
        
        var c4 = [NSLayoutConstraint]()
        actionItemView.translatesAutoresizingMaskIntoConstraints = false
        c4.append(actionItemView.topAnchor.constraint(equalTo: actionItemHeader.bottomAnchor, constant: 1.0))
        actionItemsCenter = actionItemView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor)
        actionItemsLeft = actionItemView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 10)
//        c4.append(actionItemView.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -padding))
        
        var c5 = [NSLayoutConstraint]()
        digiIDBtn.translatesAutoresizingMaskIntoConstraints = false
        c5.append(digiIDBtn.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -padding))
        c5.append(digiIDBtn.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -padding))
        
        [c0, c1, c2, c3, c4, c5].forEach { $0.forEach({ $0.isActive = true }) }
    }
    
    private func setStyle() {
        mainView.backgroundColor = .clear
        
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            // Fallback on earlier versions
            self.preferredContentSize = CGSize(width: 0, height: 300)
        }
    }
    
    private func setContent() {
        receiveHeaderLabel.text = "Your receive address:"
        receiveHeaderLabel.font = UIFont.boldSystemFont(ofSize: 12)
        receiveHeaderLabel.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1.0)
        
        receiveAddressLabel.text = "XXX"
        receiveAddressLabel.font = UIFont.boldSystemFont(ofSize: 14)
        receiveAddressLabel.lineBreakMode = .byCharWrapping
        
        actionItemHeader.text = "Actions"
        actionItemHeader.font = UIFont.boldSystemFont(ofSize: 12)
        actionItemHeader.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1.0)
        
        qrImage.backgroundColor = UIColor.white
        
        actionItemView.axis = .horizontal
        actionItemView.alignment = .fill
        actionItemView.distribution = .fill
        actionItemView.spacing = 5.0
    }
    
    private func addEvents() {
        let gr = UITapGestureRecognizer(target: self, action: #selector(addressLabelClicked))
        receiveAddressLabel.isUserInteractionEnabled = true
        receiveAddressLabel.addGestureRecognizer(gr)
        
        let gr2 = UITapGestureRecognizer(target: self, action: #selector(qrImageClicked))
        qrImage.isUserInteractionEnabled = true
        qrImage.addGestureRecognizer(gr2)
    }
    
    @objc
    private func qrImageClicked() {
        guard let address = receiveAddressLabel.text else { return }
        
        qrImage.alpha = 0.7
        
        let pb = UIPasteboard.general
        let type = UIPasteboard.typeListImage[0] as! String
        if !type.isEmpty,
            let qrImage = UIImage.qrCode(data: address.data(using: .utf8)!, color: CIColor(color: .black))?
                .resize(CGSize(width: QRImageHeight, height: QRImageHeight)),
            let qrImageLogo = UserDefaults.excludeLogoInQR ? qrImage : placeLogoIntoQR(qrImage, width: 512, height: 512),
            let imgData = qrImageLogo.jpegData(compressionQuality: 1.0) {
            
            pb.setData(imgData, forPasteboardType: type)
            if let readData = pb.data(forPasteboardType: type) {
                let _ = UIImage(data: readData, scale: 2)
                
                self.showClipboardSuccess("QR image copied to clipboard.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.qrImage.alpha = 1.0
                })
                return
            }
        }
        
        self.qrImage.alpha = 1.0
    }
    
    @objc
    private func addressLabelClicked() {
        UIPasteboard.general.string = receiveAddressLabel.text
        
        receiveAddressLabel.textColor = UIColor.gray
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.receiveAddressLabel.textColor = UIColor.black
            self.showClipboardSuccess("Your address was copied to clipboard.")
        })
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if let address = app.object(forKey: APP_GROUP_RECEIVE_ADDRESS_KEY) as? String {
            guard receiveAddressLabel.text != address else {
                completionHandler(NCUpdateResult.noData)
                return
            }
            
            receiveAddressLabel.text = address
            
            if let image = UIImage.qrCode(data: address.data(using: .utf8)!, color: CIColor(color: .black))?
                .resize(CGSize(width: QRImageHeight, height: QRImageHeight))! {
                qrImage.image = placeLogoIntoQR(image, width: QRImageHeight, height: QRImageHeight)
            } else {
                qrImage.image = nil
            }
            
            completionHandler(NCUpdateResult.newData)
        } else {
            completionHandler(NCUpdateResult.failed)
        }
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            showLarge(maxSize)
        } else {
            showSmall(maxSize)
        }
    }
    
    private func showLarge(_ maxSize: CGSize) {
        self.preferredContentSize = CGSize(width: maxSize.width, height: 330)
        
        self.qrImage.alpha = 0.0
        
        // Do not animate if already center aligned
        guard self.receiveAddressLabel.textAlignment != .center else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.receiveAddressLabel.alpha = 0.0
            self.actionItemHeader.alpha = 0.0
            self.receiveHeaderLabel.alpha = 0.0
            self.qrImageConstraint.constant = QRImageHeight
            self.qrImage.alpha = 1.0
            self.mainView.layoutIfNeeded()
            self.actionItemView.alpha = 0.0
        }) { _ in
            self.receiveAddressLabel.textAlignment = .center
            self.receiveHeaderLabel.textAlignment = .center
            self.actionItemHeader.textAlignment = .center
            
            self.actionItemsLeft.isActive = false
            self.actionItemsCenter.isActive = true
            
            UIView.animate(withDuration: 0.3, animations: {
                self.actionItemHeader.alpha = 1.0
                self.receiveHeaderLabel.alpha = 1.0
                self.receiveAddressLabel.alpha = 1.0
                self.receiveHeaderLabelConstraint.constant = padding
                self.actionLabelConstraint.constant = 10.0
                self.actionItemView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    private func showSmall(_ maxSize: CGSize) {
        self.preferredContentSize = CGSize(width: maxSize.width, height: 110)
        
        self.qrImage.alpha = 1.0
        
        // Do not animate if already left aligned
        guard self.receiveAddressLabel.textAlignment != .left else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.receiveAddressLabel.alpha = 0.0
            self.actionItemHeader.alpha = 0.0
            self.receiveHeaderLabel.alpha = 0.0
            self.qrImage.alpha = 0.0
            self.qrImageConstraint.constant = 0.0
            self.mainView.layoutIfNeeded()
            self.actionItemView.alpha = 0.0
        }) { _ in
            self.receiveAddressLabel.textAlignment = .left
            self.receiveHeaderLabel.textAlignment = .left
            self.actionItemHeader.textAlignment = .left
            
            self.actionItemsLeft.isActive = true
            self.actionItemsCenter.isActive = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.actionItemHeader.alpha = 1.0
                self.receiveHeaderLabel.alpha = 1.0
                self.receiveAddressLabel.alpha = 1.0
                self.receiveHeaderLabelConstraint.constant = -2.0
                self.actionLabelConstraint.constant = 6.0
                self.actionItemView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    
        
    }
    
    private func showClipboardSuccess(_ message: String) {
        let view = SuccessMessage(message: message)
        view.show(above: mainView)
    }
}
