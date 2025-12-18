//
//  BaseVC.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import Foundation
import UIKit

class BaseVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadAppData), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .getButtonBgColor()
        
        return refreshControl
    }()
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navBarConfig()
        self.addLeftBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.hideNavigationBottomShadow()
        
        APPDELEOBJ.navController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
}


// MARK: -
// MARK: - Call Back
extension BaseVC {
    
    func navBarConfig() {
        
        // Navigation Bar configuration
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.getTextColor()]
        
        appearance.backgroundColor = .getBgColor()
        appearance.shadowColor = .getBgColor()
        
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        
        self.navigationController?.navigationBar.tintColor = .getTextColor()
        self.navigationItem.rightBarButtonItem?.tintColor = .getTextColor()
    }
    
    func addLeftBarButton(isShow: Bool = false) {
        
        let backBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackArrowIcon"), style: .plain, target: self, action: #selector(self.back(_:)))
        
        if isShow {
            self.navigationItem.setLeftBarButtonItems([backBtn], animated: true)
        } else {
            self.navigationItem.leftBarButtonItems = nil
        }
    }
}


// MARK: -
// MARK: - Button Touch & Action
extension BaseVC {
    
    @objc func back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reloadAppData() { }
}
