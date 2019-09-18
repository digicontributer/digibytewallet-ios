//
//  DABurnViewController.swift
//  digibyte
//
//  Created by Yoshi Jaeger on 29.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

class DABurnViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Burn", image: UIImage(named: "da-burn")?.withRenderingMode(.alwaysTemplate), tag: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
