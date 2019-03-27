//
//  DAOnboardingViewController.swift
//  digibyte
//
//  Created by Julian Jäger on 28.02.19.
//  Copyright © 2019 breadwallet LLC. All rights reserved.
//

import UIKit

class DAMainViewController: UIViewController {
    // MARK: Public properties
    
    
    // MARK: Private properties
    private let header = ModalHeaderView(title: "DigiAssets", style: ModalHeaderViewStyle.light)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        addSubviews()
        addConstraints()
        
        
    }
    
    private func addSubviews() {
        view.addSubview(header)
    }
    
    private func addConstraints() {
        header.constrain([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: E.isIPhoneXOrGreater ? 30.0 : 20.0),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: C.Sizes.headerHeight)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
