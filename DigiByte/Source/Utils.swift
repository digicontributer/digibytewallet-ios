//
//  Utils.swift
//  digibyte
//
//  Created by Yoshi Jaeger on 29.04.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

func placeLogoIntoQR(_ image: UIImage, width: CGFloat, height: CGFloat, logo: UIImage? = UIImage(named: "DigiByteSymbol")) -> UIImage? {
    let img = image.resize(CGSize(width: width, height: height))
    UIGraphicsBeginImageContext(CGSize(width: width, height: height))
    img?.draw(at: CGPoint.zero)
    let ctx = UIGraphicsGetCurrentContext()!
    
    ctx.saveGState()
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)
    
    let size = width / 3.5
    let logoSize = width / 4.0
    
    let rect = CGRect(x: width / 2 - size / 2, y: height / 2 - size / 2, width: size, height: size)
    ctx.interpolationQuality = .high
    ctx.setFillColor(UIColor.white.cgColor)
    ctx.fillEllipse(in: rect)
    
    let logo = logo?.resize(CGSize(width: logoSize, height: logoSize), interpolation: true)
    logo?.draw(at: CGPoint(x: width / 2 - logoSize / 2, y: height / 2 - logoSize / 2))
    
    ctx.restoreGState()
    
    let res = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return res
}
