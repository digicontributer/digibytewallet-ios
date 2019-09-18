//
//  UserDefaults+Shared.swift
//  digibyte
//
//  Created by Julian Jäger on 04.05.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import Foundation

let APP_GROUP = "group.org.digibytefoundation.DigiByte"
private let excludeLogoInQRKey = "excludeLogoInQR"
private let shared = UserDefaults(suiteName: APP_GROUP)

extension UserDefaults {
    static var excludeLogoInQR: Bool {
        get {
            return shared?.bool(forKey: excludeLogoInQRKey) ?? false
        }
        set { shared?.set(newValue, forKey: excludeLogoInQRKey) }
    }
}
