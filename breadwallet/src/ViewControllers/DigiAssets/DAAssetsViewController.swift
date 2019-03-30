//
//  DAAssetsViewController.swift
//  digibyte
//
//  Created by Julian Jäger on 29.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

class DAButton {
    
}

class DAAssetsViewController: UIViewController {
    private let emptyImage: UIImageView = UIImageView()
    private let emptyContainer = UIView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Assets", image: UIImage(named: "da-assets")?.withRenderingMode(.alwaysTemplate), tag: 0)
        
        emptyImage.image = UIImage(named: "da-empty")
        
        addSubviews()
    }
    
    private func addSubviews() {
        emptyContainer.addSubview(emptyImage)
        view.addSubview(emptyContainer)
        
        emptyImage.constrain([
            emptyImage.widthAnchor.constraint(equalTo: emptyContainer.widthAnchor, multiplier: 1.0),
            emptyImage.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            emptyImage.topAnchor.constraint(equalTo: emptyContainer.topAnchor),
            
            emptyImage.bottomAnchor.constraint(equalTo: emptyContainer.bottomAnchor)
        ])
        
        emptyContainer.constrain([
            emptyContainer.widthAnchor.constraint(equalToConstant: 198),
            emptyContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
