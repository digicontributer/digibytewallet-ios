//
//  UIFont+DAAdditions.swift
//  digibyte
//
//  Created by Yoshi Jäger on 30.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

extension UIFont {
    /* digiassets */
    struct da {
        static func customBold(size: CGFloat) -> UIFont {
            guard let font = UIFont(name: "Lato-Bold", size: size) else { return UIFont.preferredFont(forTextStyle: .headline) }
            return font
        }
        
        static func customBody(size: CGFloat) -> UIFont {
            guard let font = UIFont(name: "Lato-Regular", size: size) else {
                return UIFont.preferredFont(forTextStyle: .subheadline)
            }
            return font
        }
        
        static func customMedium(size: CGFloat) -> UIFont {
            guard let font = UIFont(name: "Lato-Medium", size: size) else { return UIFont.preferredFont(forTextStyle: .body) }
            return font
        }
    }
}
