//
//  DADetailViewController.swift
//  DigiByte
//
//  Created by Yoshi Jaeger on 08.12.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

class DADetailViewController: UIViewController {
    
    private let store: BRStore
    private let wallet: BRWallet
    private let assetModel: AssetModel
    
    init(store: BRStore, wallet: BRWallet, assetModel: AssetModel) {
        self.store = store
        self.wallet = wallet
        self.assetModel = assetModel
        
        super.init(nibName: nil, bundle: nil)
        
        addSubviews()
        addConstraints()
        addEvents()
        
        setStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        
    }
    
    private func addConstraints() {
           
    }
       
    private func addEvents() {
           
    }
       
    private func setStyle() {
        view.backgroundColor = .white
    }
}
