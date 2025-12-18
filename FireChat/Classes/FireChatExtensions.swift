//
//  FireChatExtensions.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import Foundation
import UIKit
import SafariServices

// MARK: - UIViewController
extension UIViewController {
    
    // Add Navigation Bottom Shadow
    func hideNavigationBottomShadow() {
        
        self.navigationController?.navigationBar.layer.masksToBounds = true
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.getClearColour().cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
    }
    
    // Get Top & Bottom bar height
    var getNavBarHeight: CGFloat {
        return (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var getTabBarHeight: CGFloat {
        return (self.tabBarController?.tabBar.frame.size.height ?? 49.0)
    }
    
    // Show Alert Message
    func showAlertMessage(titleStr: String, messageStr: String) {
        
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func openSafariVC(url: URL) {
        
        if isConnectedToInternet() {
            
            let safariVC = SFSafariViewController(url: url)
            safariVC.preferredBarTintColor = .getBgColor()
            safariVC.preferredControlTintColor = .getTextColor()
            safariVC.dismissButtonStyle = .close
            safariVC.hidesBottomBarWhenPushed = true
            self.present(safariVC, animated: true)
        }
    }
}


// MARK: - UIView
extension UIView {
    
    func addRadiusWithBorder(radius: CGFloat = 10, border: CGFloat = 0.0) {
        
        self.layer.cornerRadius = radius
        if #available(iOS 13.0, *) {
            self.layer.cornerCurve = .continuous
        }
        self.layer.borderWidth = border
    }
    
    func addTableFooter(width: CGFloat = SCREENWIDTH, height: CGFloat = 0) -> UIView {
        return UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
}


// MARK: - UITextField
extension UITextField {
    
    func setTextFieldFont() {
        self.font = .systemFont(ofSize: 15, weight: .medium)
        self.textAlignment = .left
    }
    
    func setLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


// MARK: - UIButton
extension UIButton {
    
    // Set BackgroundColor
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
    
    // Solid Button
    func solidFilledBtn() {
        
        self.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        self.titleLabel?.lineBreakMode = .byClipping
        self.showsTouchWhenHighlighted = false
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false
    }
    
    func solidFilledBtn(radius: CGFloat?) {
        
        self.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        self.titleLabel?.lineBreakMode = .byClipping
        self.showsTouchWhenHighlighted = false
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false
        
        if let r = radius {
            self.addRadiusWithBorder(radius: r)
        }
    }
    
    // -------------------- Scale Transform Animation -------------------- //
    func startAnimatingPressActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.94, y: 0.94))
        // animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 1.06, y: 1.06))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
            button.transform = transform
        }, completion: nil)
    }
}


// MARK: - String
extension String {
    
    func removeMultipleSpace(withNewline: Bool) -> String {
        
        if withNewline {
            return self.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
        } else {
            return self.replacingOccurrences(of: "[\\s]+", with: " ", options: .regularExpression, range: nil)
        }
    }
}


// MARK: - Date
extension Date {
    
    func strippedTime() -> Date {
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: self)
    }
}


// MARK: - UIColor
extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        
        var hexString = ""
        
        if hex.hasPrefix("#") {
            let nsHex = hex as NSString
            hexString = nsHex.substring(from: 1)
        } else {
            hexString = hex
        }
        
        let scanner = Scanner(string: hexString)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch hexString.count {
            case 3:
                red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
                blue = CGFloat(hexValue & 0x00F) / 15.0
            case 6:
                red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                blue = CGFloat(hexValue & 0x0000FF) / 255.0
            default:
                debugPrint("Invalid HEX string, number of characters after '#' should be either 3, 6", terminator: "")
            }
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func getClearColour() -> UIColor {
        return UIColor.clear
    }
    
    class func getBgColor(alpha: CGFloat = 1.0) -> UIColor {
        return (UIColor(named: "Background_Color")?.withAlphaComponent(alpha))!
    }
    
    class func getTextColor(alpha: CGFloat = 1.0) -> UIColor {
        return (UIColor(named: "Text_Color")?.withAlphaComponent(alpha))!
    }
    
    class func getButtonBgColor(alpha: CGFloat = 1.0) -> UIColor {
        return (UIColor(named: "ButtonBg_Color")?.withAlphaComponent(alpha))!
    }
    
    class func getButtonTextColor(alpha: CGFloat = 1.0) -> UIColor {
        return (UIColor(named: "ButtonText_Color")?.withAlphaComponent(alpha))!
    }
    
    class func getPlaceholderTextColor() -> UIColor {
        return UIColor(named: "TextPlaceholder_Color")!
    }
    
    class func getSelectedBorderColor() -> UIColor {
        return UIColor(named: "SelectedBorder_Color")!
    }
    
    class func getUnSelectedBorderColor() -> UIColor {
        return UIColor(named: "UnSelectedBorder_Color")!
    }
    
    class func getHSeparatorColor() -> UIColor {
        return UIColor(named: "HSeparator_Color")!
    }
    
    class func getCardBgColor() -> UIColor {
        return UIColor(named: "CardBg_Color")!
    }
    
    class func getChatSelfBgColor() -> UIColor {
        return UIColor(named: "ChatSelfBg_Color")!
    }
    
    class func getChatOtherBgColor() -> UIColor {
        return UIColor(named: "ChatOtherBg_Color")!
    }
}


// MARK: - UIDevice
extension UIDevice {
    
    var hasNotch: Bool {
        let bottom = WINDOWSCENE?.windows.first?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
