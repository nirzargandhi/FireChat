//
//  AppDelegate.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import SDWebImage

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    internal var window: UIWindow?
    var navController : UINavigationController?
    var isRestrictRotation: Bool = true
    
    
    // MARK: - RootView Setup
    func setRootViewController(rootVC: UIViewController) {
        
        self.navController = UINavigationController(rootViewController: rootVC)
        self.window?.rootViewController = self.navController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase Configuration
        FirebaseApp.configure()
        clearFirestoreCache()
        
        // Set Root Controller
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .getBgColor()
        
        if let _ = Auth.auth().currentUser {
            setRootHomeVC()
        } else {
            setRootSignInVC()
        }
        
        self.window?.makeKeyAndVisible()
        
        // Keyboard Appearance
        keyboardAppearance()
        
        // SDImage Cache Clear
        sdImageCacheClear()
        
        // UIButton Appearance
        UIButton.appearance().isExclusiveTouch = true
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if self.isRestrictRotation {
            return UIInterfaceOrientationMask.portrait
        }
        
        return UIInterfaceOrientationMask.all
    }
}
