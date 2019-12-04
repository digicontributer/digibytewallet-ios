//
//  DAOnboardingViewController.swift
//  digibyte
//
//  Created by Yoshi Jaeger on 28.02.19.
//  Copyright © 2019 breadwallet LLC. All rights reserved.
//

import UIKit

class DAMainViewController: UITabBarController {
    // MARK: Public properties
    
    // MARK: Private properties
    private let header = ModalHeaderView(title: "DigiAssets", style: ModalHeaderViewStyle.light)
    
    private var tabs = [DAAssetsViewController(), DASendViewController(), DAReceiveViewController(), DACreateViewController(), DABurnViewController()]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        addSubviews()
        addConstraints()
        setStyle()
        
        viewControllers = tabs
        tabBar.tintColor = UIColor(red: 38 / 255, green: 152 / 255, blue: 237 / 255, alpha: 1.0) //  38 152 237
        tabBar.barTintColor = UIColor(red: 35 / 255, green: 35 / 255, blue: 60 / 255, alpha: 1.0) //  35 35 60
        tabBar.isTranslucent = false
        
        if #available(iOS 10.0, *) {
            tabBar.unselectedItemTintColor = UIColor(red: 47 / 255, green: 49 / 255, blue: 80 / 255, alpha: 1.0) // 47 49 80
        } else {
            // what will we do below ios10 ?
        }
        
        header.close.tap = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func addSubviews() {
        view.addSubview(header)
    }
    
    private func addConstraints() {
        header.constrain([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: E.isIPhoneXOrGreater ? 40.0 : 20.0),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: C.Sizes.headerHeight)
        ])
    }
    
    private func setStyle() {
        view.backgroundColor = UIColor.da.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
