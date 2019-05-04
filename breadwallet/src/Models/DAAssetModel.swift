//
//  DAAssetModel.swift
//  digibyte
//
//  Created by Yoshi Jäger on 31.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import Foundation

struct DAAssetModel: Codable {
    let name: String
    let amount: Int
    let iconUrl: String?
    
    init(name: String, amount: Int, iconUrl: String? = nil) {
        self.name = name
        self.amount = amount
        self.iconUrl = iconUrl
    }
}
