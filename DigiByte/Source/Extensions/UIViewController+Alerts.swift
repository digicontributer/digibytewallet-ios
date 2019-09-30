//
//  UIViewController+Alerts.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-07-04.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

extension UIViewController {

    func showErrorMessage(_ message: String) {
        let alert = AlertController(title: S.Alert.error, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(title: S.Button.ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showAlert(title: String, message: String, buttonLabel: String) {
        let alertController = AlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(AlertAction(title: S.Button.ok, style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
