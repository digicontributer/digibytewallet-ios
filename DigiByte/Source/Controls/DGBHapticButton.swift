//
//  HapticButton.swift
//  digibyte
//
//  Created by Yoshi Jaeger on 31.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

class DGBHapticButton: UIButton {
    private var feedbackGenerator: AnyObject? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if #available(iOS 10.0, *) {
            feedbackGenerator = UISelectionFeedbackGenerator()
            (feedbackGenerator as? UISelectionFeedbackGenerator)?.prepare()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if #available(iOS 10.0, *) {
            if let f = feedbackGenerator as? UISelectionFeedbackGenerator {
                f.selectionChanged()
                feedbackGenerator = nil
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if #available(iOS 10.0, *) {
            feedbackGenerator = nil
        }
    }
}
