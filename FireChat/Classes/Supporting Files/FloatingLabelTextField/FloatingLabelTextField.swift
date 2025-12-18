//
//  FloatingLabelTextField.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import UIKit

class FloatingLabelTextField: UITextField {
    
    // MARK: - Properties
    fileprivate let floatingLabel = UILabel()
    fileprivate let borderLayer = CAShapeLayer()
    
    fileprivate let cornerRadius: CGFloat = 8
    fileprivate let floatingLabelX: CGFloat = 15
    
    fileprivate lazy var floatingLabelWidth = CGFloat()
    fileprivate let floatingLabelHeight: CGFloat = 18
    
    fileprivate lazy var isLabelFloated = false
    fileprivate lazy var placeHolderStr = ""
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setup()
    }
    
    fileprivate func setup() {
        
        // TextField
        self.backgroundColor = .getClearColour()
        self.textColor = .getTextColor()
        self.tintColor = .getTextColor()
        self.setTextFieldFont()
        self.autocorrectionType = .no
        
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        
        // Border Layer
        self.borderLayer.strokeColor = UIColor.getUnSelectedBorderColor().cgColor
        self.borderLayer.fillColor = UIColor.getClearColour().cgColor
        self.borderLayer.cornerRadius = self.cornerRadius
        self.borderLayer.lineWidth = 1
        self.layer.addSublayer(self.borderLayer)
        
        // Floating label
        self.floatingLabel.backgroundColor = .getClearColour()
        self.floatingLabel.textColor = .getTextColor()
        self.floatingLabel.font = .systemFont(ofSize: 14, weight: .regular)
        self.floatingLabel.textAlignment = .center
        self.floatingLabel.alpha = 0
        self.addSubview(self.floatingLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateBorderPath()
        
        if !self.isLabelFloated {
            self.floatingLabel.frame = CGRect(x: self.floatingLabelX, y: self.bounds.height/2, width: self.floatingLabelWidth, height: self.floatingLabelHeight)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.updateTextFieldUI()
        }
    }
}


// MARK: - Call Back
extension FloatingLabelTextField {
    
    func updateProperty(leftPadding: CGFloat = 15, rightPadding: CGFloat = 15, placeholderText: String, floatingLabelText: String) {
        
        self.setLeftPadding(width: leftPadding)
        self.setRightPadding(width: rightPadding)
        
        self.placeHolderStr = placeholderText
        self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.getPlaceholderTextColor()])
        
        self.floatingLabel.text = floatingLabelText
        
        self.floatingLabelWidth = getTextWidth(text: floatingLabelText, font: .systemFont(ofSize: 14)).width
        self.floatingLabel.frame = CGRect(x: self.floatingLabelX, y: self.bounds.height/2, width: self.floatingLabelWidth, height: self.floatingLabelHeight)
    }
    
    
    // MARK: - Update Border Path
    fileprivate func updateBorderPath() {
        
        let rect = bounds
        let path = UIBezierPath()
        
        if self.isLabelFloated {
            let labelWidth = self.floatingLabel.intrinsicContentSize.width + 8
            let labelX = self.floatingLabel.frame.minX - 4
            let gapStart = max(labelX, self.cornerRadius)
            let gapEnd = min(labelX + labelWidth, rect.width - self.cornerRadius)
            
            // Left arc
            path.move(to: CGPoint(x: rect.minX + self.cornerRadius, y: rect.minY))
            path.addArc(withCenter: CGPoint(x: rect.minX + self.cornerRadius, y: rect.minY + self.cornerRadius),
                        radius: self.cornerRadius,
                        startAngle: CGFloat.pi * 1.5,
                        endAngle: CGFloat.pi,
                        clockwise: false)
            
            // Left side
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - self.cornerRadius))
            path.addArc(withCenter: CGPoint(x: rect.minX + self.cornerRadius, y: rect.maxY - self.cornerRadius),
                        radius: self.cornerRadius,
                        startAngle: CGFloat.pi,
                        endAngle: CGFloat.pi / 2,
                        clockwise: false)
            
            // Bottom side
            path.addLine(to: CGPoint(x: rect.maxX - self.cornerRadius, y: rect.maxY))
            path.addArc(withCenter: CGPoint(x: rect.maxX - self.cornerRadius, y: rect.maxY - self.cornerRadius),
                        radius: self.cornerRadius,
                        startAngle: CGFloat.pi / 2,
                        endAngle: 0,
                        clockwise: false)
            
            // Right side
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + self.cornerRadius))
            path.addArc(withCenter: CGPoint(x: rect.maxX - self.cornerRadius, y: rect.minY + self.cornerRadius),
                        radius: self.cornerRadius,
                        startAngle: 0,
                        endAngle: CGFloat.pi * 1.5,
                        clockwise: false)
            
            // Top border with gap
            path.addLine(to: CGPoint(x: gapEnd, y: rect.minY))
            path.move(to: CGPoint(x: gapStart, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + self.cornerRadius, y: rect.minY))
            
        } else {
            // Normal rounded rect
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: self.cornerRadius))
        }
        
        self.borderLayer.path = path.cgPath
    }
    
    
    // MARK: - TextField State Change
    @objc fileprivate func editingChanged() {
        self.updateTextFieldUI()
    }
    
    @objc fileprivate func editingDidBegin() {
        
        self.floatLabelUp()
        
        self.attributedPlaceholder = nil
    }
    
    @objc fileprivate func editingDidEnd() {
        self.updateTextFieldUI()
    }
    
    
    // MARK: - Update TextField UI
    @objc func updateTextFieldUI() {
        
        if let t = self.text, !t.isEmpty {
            
            self.floatLabelUp()
            self.borderLayer.strokeColor = UIColor.getSelectedBorderColor().cgColor
            
        } else {
            
            if self.isFirstResponder {
                
                self.floatLabelUp()
                self.borderLayer.strokeColor = UIColor.getUnSelectedBorderColor().cgColor
                
            } else {
                
                self.attributedPlaceholder = NSAttributedString(string: self.placeHolderStr, attributes: [NSAttributedString.Key.foregroundColor: UIColor.getPlaceholderTextColor()])
                
                self.floatLabelDown()
                self.borderLayer.strokeColor = UIColor.getUnSelectedBorderColor().cgColor
            }
        }
    }
    
    
    // MARK: - Float Label Up & Down
    fileprivate func floatLabelUp() {
        
        guard !isLabelFloated else { return }
        
        self.isLabelFloated = true
        
        UIView.animate(withDuration: 0.1) {
            self.floatingLabel.alpha = 1
            self.floatingLabel.frame = CGRect(x: self.floatingLabelX, y: -10, width: self.floatingLabelWidth, height: self.floatingLabelHeight)
        } completion: { _ in
            self.updateBorderPath()
        }
    }
    
    fileprivate func floatLabelDown() {
        
        guard self.isLabelFloated else { return }
        
        self.isLabelFloated = false
        
        UIView.animate(withDuration: 0.1) {
            self.floatingLabel.alpha = 0
            self.floatingLabel.frame = CGRect(x: self.floatingLabelX, y: self.bounds.height/2, width: self.floatingLabelWidth, height: self.floatingLabelHeight)
        } completion: { _ in
            self.updateBorderPath()
        }
    }
}
