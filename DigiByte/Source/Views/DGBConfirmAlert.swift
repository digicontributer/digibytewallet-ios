//
//  DGBConfirmAlert.swift
//  DigiByte
//
//  Created by Yoshi Jaeger on 01.12.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

fileprivate class ConfirmButton: DGBHapticButton {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? backgroundColor!.withAlphaComponent(0.8) : backgroundColor!.withAlphaComponent(1.0)
        }
    }
}

class DAModalAssetSelector: DGBModalWindow {
    var callback: ((AssetModel?) -> Void)? = nil
    
    init() {
        super.init(title: "Select an asset", padding: 0)
        
        let tv = UITableView()
        stackView.addArrangedSubview(tv)
        
        let hC = tv.heightAnchor.constraint(equalToConstant: 300)
        hC.priority = .defaultLow
        hC.isActive = true
        
        tv.delegate = self
        tv.dataSource = self
        tv.separatorInset = UIEdgeInsets.zero
        
        tv.register(DAModalAssetSelectorCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DAModalAssetSelectorCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
//        guard let iv = imageView else { return }
//        iv.constrain([
//            iv.heightAnchor.constraint(equalToConstant: 32),
//            iv.widthAnchor.constraint(equalToConstant: 32),
//        ])
//
//        iv.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = CGRect(x: 22, y: 12, width: 32, height: 32)
        self.imageView?.frame = bounds
        self.imageView?.contentMode = .scaleAspectFit
        
        var tempFrame: CGRect!
        let targetX: CGFloat = 77
        var shift: CGFloat!
        
        tempFrame = textLabel!.frame
        shift = tempFrame.origin.x - targetX
        tempFrame.origin.x = targetX
        textLabel!.frame = CGRect(x: tempFrame.origin.x, y: tempFrame.origin.y, width: tempFrame.width + shift, height: tempFrame.height)
        
        tempFrame = detailTextLabel!.frame
        shift = tempFrame.origin.x - targetX
        tempFrame.origin.x = targetX
        detailTextLabel!.frame = CGRect(x: tempFrame.origin.x, y: tempFrame.origin.y, width: tempFrame.width + shift, height: tempFrame.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DAModalAssetSelector: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AssetHelper.allAssets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let assetId = AssetHelper.allAssets[indexPath.row]
        let assetModel = AssetHelper.getAssetModel(assetID: assetId) ?? AssetModel.dummy()
    
        cell.textLabel?.text = assetModel.getAssetName()
        
        let description = assetModel.getDescription()
        let amount = AssetHelper.allBalances[assetId]
        let amountStr: String? = amount == nil ? nil : "\(amount!)"
        let subtitleStr = [amountStr, description].compactMap({ $0 }).joined(separator: " | ")
        cell.detailTextLabel?.text = subtitleStr
        
        if let urlStr = assetModel.getImage()?.url, let url = URL(string: urlStr) {
            cell.imageView?.kf.setImage(with: url)
            cell.imageView?.tintColor = .clear
        } else {
            cell.imageView?.image = UIImage(named: "digiassets_small")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor.black.withAlphaComponent(0.7)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assetId = AssetHelper.allAssets[indexPath.row]
        let assetModel = AssetHelper.getAssetModel(assetID: assetId)
        callback?(assetModel)
        dismiss(animated: true, completion: nil)
    }
}

class DGBModalWindow: UIViewController, UIGestureRecognizerDelegate {
    private let headerTitle: String
    private let titleView = UIView()
    private let titleLabel = UILabel()
    private var tap: UITapGestureRecognizer!
    
    private let padding: CGFloat
    
    let containerView = UIView()
    let stackView = UIStackView()
    
    init(title: String, padding: CGFloat = 8.0) {
        self.headerTitle = title
        self.padding = padding
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self

        addSubviews()
        addConstraints()
        setStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.view.window?.addGestureRecognizer(tap)
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self.containerView)
        
        if location.x < 0 || location.x > self.containerView.bounds.width {
            return true
        }
        
        if location.y < 0 || location.y > self.containerView.bounds.height {
            return true
        }
        
        return false
    }

    @objc private func onTap(sender: UITapGestureRecognizer) {
        self.view.window?.removeGestureRecognizer(sender)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addSubviews() {
        view.addSubview(containerView)
        
        titleView.addSubview(titleLabel)
        containerView.addSubview(titleView)
        containerView.addSubview(stackView)
    }
    
    private func addConstraints() {
        containerView.constrainToCenter()
        
        containerView.constrain([
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8),
        ])
        
        titleView.constrain([
            titleView.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            titleView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
        ])
        
        stackView.constrain([
            stackView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: padding),
            stackView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: padding),
            stackView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
        ])
        titleLabel.constrain(toSuperviewEdges: UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding))
    }
    
    private func setStyle() {
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.white
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        titleView.backgroundColor = UIColor.da.darkSkyBlue
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.text = headerTitle
        titleLabel.font = UIFont.da.customBold(size: 18)
        titleLabel.lineBreakMode = .byWordWrapping
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DGBModalWindow: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DGBModalAnimationController(false)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DGBModalAnimationController(true)
    }
}

class DGBModalAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    
    init(_ presenting: Bool) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.15
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let vc = transitionContext.viewController(forKey: presenting ? .to : .from)!
        let containerView = transitionContext.containerView
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        vc.view.alpha = presenting ? 0.0 : 1.0
        vc.view.transform = presenting ? CGAffineTransform(scaleX: 0.9, y: 0.9) : CGAffineTransform.identity
        
        if presenting {
            containerView.addSubview(vc.view)
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            vc.view.alpha = self.presenting ? 1.0 : 0.0
            vc.view.transform = self.presenting ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

typealias DGBCallback = (() -> Void)

class DGBModalLoadingView: DGBModalWindow {
    let ai: UIActivityIndicatorView
    var gr: UITapGestureRecognizer!
    var tapCount = 0
    
    init(title: String) {
        ai = UIActivityIndicatorView(style: .gray)
        super.init(title: title)
        
        ai.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.addArrangedSubview(ai)
        
        gr = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gr)
    }
    
    @objc
    private func tapped() {
        // Safe exit (if no outer vc ever dismissed modalLoadingView)
        tapCount = tapCount + 1
        if tapCount >= 3 { self.dismiss(animated: true, completion: nil) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ai.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ai.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DGBConfirmAlert: DGBModalWindow {
    let message: String
    let image: UIImage?
    let okTitle: String
    let cancelTitle: String
    
    var confirmCallback: ((DGBCallback) -> Void)? = nil
    var cancelCallback: ((DGBCallback) -> Void)? = nil
    var alternativeCallback: ((DGBCallback) -> Void)? = nil
    
    private let contentLabel = UILabel()
    
    private let buttonsView = UIStackView()
    
    private var imageContainer = UIView()
    private var imageView: UIImageView!
    private var okButton: ConfirmButton!
    private var cancelButton: ConfirmButton!
    
    private let alternativeTitle: String?
    
    init(title: String, message: String, image: UIImage?, okTitle: String = S.Alerts.defaultConfirmOkCaption, cancelTitle: String = S.Alerts.defaultConfirmCancelCaption, alternativeButtonTitle: String? = nil) {
        
        self.message = message
        self.image = image
        self.okTitle = okTitle
        self.cancelTitle = cancelTitle
        self.alternativeTitle = alternativeButtonTitle
        
        super.init(title: title)
        
        imageView = UIImageView(image: image)
    
        okButton = ConfirmButton()
        cancelButton = ConfirmButton()
        
        addSubviews()
        addConstraints()
        setStyle()
        addEvents()
    }
    
    private func addSubviews() {
        // add buttons
        buttonsView.addArrangedSubview(okButton)
        buttonsView.addArrangedSubview(cancelButton)
        
        // add vertical views
        if image != nil {
            imageContainer.addSubview(imageView)
            stackView.addArrangedSubview(imageContainer)
        }
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(buttonsView)
        
        if let title = alternativeTitle {
            let alternativeButton = UIButton()
            alternativeButton.setTitle(title, for: .normal)
            alternativeButton.setTitleColor(UIColor.gray, for: .normal)
            alternativeButton.titleLabel?.textAlignment = .center
            alternativeButton.titleLabel?.font = UIFont.da.customMedium(size: 12)
            alternativeButton.tap = { [weak self] in
                guard let c = self?.closeCallback else { return }
                self?.alternativeCallback?(c)
            }
            stackView.addArrangedSubview(alternativeButton)
        }
    }
    
    private func addConstraints() {
        imageView.constrain([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 0),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 180),
            imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
        ])
        
        okButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 1.0).isActive = true
        okButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor, multiplier: 1.0).isActive = true
        okButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func setStyle() {
        stackView.spacing = 16
        
        imageView.contentMode = .scaleAspectFit
        
        buttonsView.axis = .horizontal
        buttonsView.alignment = .fill
        buttonsView.distribution = .fill
        buttonsView.spacing = 8
        
        contentLabel.textAlignment = .left
        contentLabel.numberOfLines = 0
        contentLabel.text = message
        contentLabel.font = UIFont.da.customBody(size: 16)
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.textColor = UIColor.black
        
        okButton.setTitle(okTitle, for: .normal)
        cancelButton.setTitle(cancelTitle, for: .normal)
        okButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        okButton.titleLabel?.font = UIFont.da.customBody(size: 16)
        cancelButton.titleLabel?.font = UIFont.da.customBody(size: 16)
        
        okButton.backgroundColor = UIColor.da.darkSkyBlue
        okButton.layer.cornerRadius = 8
        okButton.layer.masksToBounds = true
        
        cancelButton.backgroundColor = UIColor(red: 228/255, green: 229/255, blue: 228/255, alpha: 1.0) // grey
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.masksToBounds = true
    }
    
    private func addEvents() {
        okButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    private lazy var closeCallback: DGBCallback = { () in
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func confirmTapped() {
        // User is responsible to call the close callback.
        confirmCallback?(closeCallback)
    }
    
    @objc
    private func cancelTapped() {
        cancelCallback?(closeCallback)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
