//
//  DAReceiveViewController.swift
//  digibyte
//
//  Created by Yoshi Jaeger on 29.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

class DAReceiveViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Receive", image: UIImage(named: "da-receive")?.withRenderingMode(.alwaysTemplate), tag: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
