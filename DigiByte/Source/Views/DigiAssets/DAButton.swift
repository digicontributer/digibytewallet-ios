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
        isUserInteractionEnabled = true
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

class DAGlyphedButton: DAHapticControl {
    
}

class DAButton: DAHapticControl {
    // MARK: Private
    private var _height: CGFloat
    private var heightConstraint: NSLayoutConstraint!
    
    // MARK: Public
    var stackView = UIStackView()
    var label: UILabel!
    var backgroundView: UIView!
    
    var leftImage: UIImage? = nil {
        didSet {
            recalcSubviews()
        }
    }
    
    var rightImage: UIImage? = nil {
        didSet {
            recalcSubviews()
        }
    }
    
    // TouchUpInside
    var touchUpInside: (() -> Void)? = nil
    
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
    
    private func recalcSubviews() {
        stackView.arrangedSubviews.forEach({ stackView.removeArrangedSubview($0); })
        
        guard leftImage != nil || rightImage != nil else {
            // Do not add any subviews except the label
            stackView.addArrangedSubview(label)
            return
        }
        
        do {
            let bgView = UIView()
            let height = _height - 9
            bgView.widthAnchor.constraint(equalToConstant: height).isActive = true
            
            if leftImage != nil {
                bgView.layer.cornerRadius = height / 2
                bgView.layer.masksToBounds = true
                
                bgView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                
                let iv = UIImageView(image: leftImage)
                iv.contentMode = .scaleAspectFit
                bgView.addSubview(iv)
                
                iv.constrain(toSuperviewEdges: UIEdgeInsets(top: 7, left: 7, bottom: -7, right: -7))
            }
            
            stackView.addArrangedSubview(bgView)
        }
        
        stackView.addArrangedSubview(label)
        
        do {
            let bgView = UIView()
            let height = _height - 9
            bgView.widthAnchor.constraint(equalToConstant: height).isActive = true
            
            if rightImage != nil {
                bgView.layer.cornerRadius = height / 2
                bgView.layer.masksToBounds = true
                
                bgView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                
                let iv = UIImageView(image: rightImage)
                iv.contentMode = .scaleAspectFit
                bgView.addSubview(iv)
                
                iv.constrain(toSuperviewEdges: UIEdgeInsets(top: 7, left: 7, bottom: -7, right: -7))
            }
            
            stackView.addArrangedSubview(bgView)
        }
    }
    
    init(title: String, backgroundColor: UIColor, height: CGFloat = DEFAULT_HEIGHT, radius: CGFloat? = nil) {
        _height = height
        super.init(frame: .zero)
        
        label = UILabel(font: UIFont.da.customBold(size: 19))
        backgroundView = UIView()
        
        backgroundView.addSubview(stackView)
        recalcSubviews()
        
        addSubview(backgroundView)
        
        stackView.constrain(toSuperviewEdges: UIEdgeInsets(top: 6, left: 6, bottom: -6, right: -6))
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        heightConstraint = backgroundView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        backgroundView.backgroundColor = backgroundColor
        backgroundView.layer.masksToBounds = true
        
        if let r = radius {
            backgroundView.layer.cornerRadius = r
        } else {
            backgroundView.layer.cornerRadius = height / 2
        }
        
//        label.constrain([
//            label.leftAnchor.constraint(equalTo: self.backgroundView.leftAnchor, constant: 8),
//            label.rightAnchor.constraint(equalTo: self.backgroundView.rightAnchor, constant: -8),
//            label.centerYAnchor.constraint(equalTo: self.backgroundView.centerYAnchor, constant: 0),
//        ])
//
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
        gr.touchUpCallback = { [weak backgroundView, weak self] withinButton in
            backgroundView?.frame.origin.y = 0
            if withinButton { self?.touchUpInside?() }
        }
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
    var touchUpCallback: ((Bool) -> Void)? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        touchDownCallback?()
        state = .began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        var withinButton: Bool = false
        
        if let firstTouch = touches.first {
            let touchedPoint = firstTouch.location(in: self.view)
            withinButton = self.view?.bounds.contains(touchedPoint) ?? false
        }
        
        touchUpCallback?(withinButton)
        state = .ended
    }
}
