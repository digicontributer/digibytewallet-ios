//
//  UserDefaults+PrivacyAdditions.swift
//  DigiByte
//
//  Created by Yoshi Jaeger on 03.12.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import Foundation

fileprivate let alwaysLoadAssetsKey = "alwaysLoadAssets"

extension UserDefaults {
    enum Privacy {
        static var automaticallyResolveAssets: Bool {
            get { return UserDefaults.standard.bool(forKey: alwaysLoadAssetsKey) }
            set { UserDefaults.standard.set(newValue, forKey: alwaysLoadAssetsKey) }
        }
    }
}
