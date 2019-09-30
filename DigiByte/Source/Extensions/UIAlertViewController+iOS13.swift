//
//  UIAlertViewController+showOnTop.swift
//  digibyte
//
//  Created by Yoshi Jäger on 30.09.19.
//  Copyright © 2019 DigiByte. All rights reserved.
//

import UIKit

struct AlertAction {
    var title: String?
    var style: UIAlertAction.Style
    var handler: ((UIAlertAction) -> Void)? = nil
}

public extension UIAlertController {
    @available(*, unavailable, message: "Use AlertController class instead of UIAlertController")
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}

class AlertController: UIAlertController {
    func show() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        appDelegate.alertWindow.rootViewController = vc
        appDelegate.alertWindow.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
    
    func addAction(_ inputAction: AlertAction) {
        let action = UIAlertAction(title: inputAction.title, style: inputAction.style) { (action) in
            (UIApplication.shared.delegate as! AppDelegate).alertWindow.isHidden = true
            inputAction.handler?(action)
        }
        
        super.addAction(action)
    }
    
    @available(*, unavailable, message: "Use addAction(_ action: AlertAction) instead of the default")
    override func addAction(_ action: UIAlertAction) {
        super.addAction(action)
    }
}
