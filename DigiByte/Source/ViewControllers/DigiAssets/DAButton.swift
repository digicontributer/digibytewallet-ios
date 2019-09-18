//
//  DAButton.swift
//  digibyte
//
//  Created by Yoshi Jaeger on 30.03.19.
//  Copyright © 2019 DigiByte Foundation NZ Limited. All rights reserved.
//

import UIKit

fileprivate let DEFAULT_HEIGHT: CGFloat = 23.0

class DAHapticControl: UIControl {
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

class DAButton: DAHapticControl {
    // MARK: Private
    private var _height: CGFloat
    private var heightConstraint: NSLayoutConstraint!
    
    // MARK: Public
    var label: UILabel!
    var backgroundView: UIView!
    
    var height: CGFloat {
        set {
            _height = newValue
            backgroundView.layer.cornerRadius = newValue / 2
            heightConstraint.constant = newValue
            layoutIfNeeded()
        } get {
            return _height
        }
    }
    
    init(title: String, backgroundColor: UIColor, height: CGFloat = DEFAULT_HEIGHT) {
        _height = height
        super.init(frame: .zero)
        
        label = UILabel(font: UIFont.da.customBold(size: 19))
        backgroundView = UIView()
        
        backgroundView.addSubview(label)
        addSubview(backgroundView)
        
        heightConstraint = backgroundView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        backgroundView.backgroundColor = backgroundColor
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = height / 2
        
        label.constrain([
            label.leftAnchor.constraint(equalTo: self.backgroundView.leftAnchor),
            label.rightAnchor.constraint(equalTo: self.backgroundView.rightAnchor),
            label.centerYAnchor.constraint(equalTo: self.backgroundView.centerYAnchor, constant: 0),
        ])
        
        backgroundView.constrain(toSuperviewEdges: nil)
        
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.text = title
        
        isUserInteractionEnabled = true
    
        // This is a workaround I've used to supress the delay of touchesBegan.
        // I.e. define a custom gesture recognizer that works without delay
        let gr = DAButtonGestureRecognizer(target: self, action: nil)
        gr.touchDownCallback = { [weak backgroundView] in backgroundView?.frame.origin.y = 2 }
        gr.touchUpCallback = { [weak backgroundView] in backgroundView?.frame.origin.y = 0 }
        gr.cancelsTouchesInView = false
        gr.delegate = self
        gr.delaysTouchesBegan = false
        self.addGestureRecognizer(gr)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DAButton: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

fileprivate class DAButtonGestureRecognizer: UIGestureRecognizer {
    var touchDownCallback: (() -> Void)? = nil
    var touchUpCallback: (() -> Void)? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        touchDownCallback?()
        state = .began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        touchUpCallback?()
        state = .ended
    }
    
    
}
