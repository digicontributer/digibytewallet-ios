//
//  UINavigationController+BRAdditions.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-29.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

extension UINavigationController {

    func setDefaultStyle() {
        setClearNavbar()
        setTintableBackArrow()
        
        self.navigationBar.tintColor = UIColor.white
    }

    func setWhiteStyle() {
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.customBold(size: 17.0)
        ]
        setTintableBackArrow()
    }

    func setClearNavbar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }

    func setNormalNavbar() {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
    }

    func setBlackBackArrow() {
        let image = UIImage(named: "arrow_back")
        let renderedImage = image?.withRenderingMode(.alwaysOriginal)
        navigationBar.backIndicatorImage = renderedImage
        navigationBar.backIndicatorTransitionMaskImage = renderedImage
    }

    func setTintableBackArrow() {
//        let image = UIImage(named: "arrow_back")?.withRenderingMode(.alwaysTemplate).resize(CGSize(width: 44, height: 44))
        let btn = UIButton.icon(image: UIImage(named: "arrow_back")!.withRenderingMode(.alwaysTemplate), accessibilityLabel: "Go Back")
        let barButton = UIBarButtonItem(customView: btn)
        barButton.action = #selector(backPressed)
        barButton.target = self
        
        navigationItem.leftBarButtonItem = barButton
        navigationBar.backItem?.backBarButtonItem = nil
//        navigationBar.backIndicatorTransitionMaskImage = barButton
    }
    
    @objc func backPressed() {
        popViewController(animated: true)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
