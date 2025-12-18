//
//  Constants.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import Foundation
import UIKit

let BASEWIDTH = 375.0
let SCREENSIZE: CGRect      = UIScreen.main.bounds
let SCREENWIDTH             = UIScreen.main.bounds.width
let SCREENHEIGHT            = UIScreen.main.bounds.height
let WINDOWSCENE             = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
let STATUSBARHEIGHT         = WINDOWSCENE?.statusBarManager?.statusBarFrame.size.height ?? 0.0
var NAVBARHEIGHT            = 44.0

let APPDELEOBJ  = UIApplication.shared.delegate as! AppDelegate
let NC = NotificationCenter.default
var defaultUserName = "SU"


// MARK: - Constants
struct Constants {
    
    struct Storyboard {
        
        static let Main = "Main"
    }
    
    struct Generic {
        
        // Messages
        static let SomethingWentWrong = "Sorry, something went wrong. Please try again in a while"
        static let NoDataFound = "No data found"
        
        static let FirstNameEmpty = "First name is empty"
        static let LastNameEmpty = "Last name is empty"
        
        static let EmailEmpty = "Email address is empty"
        static let EmailInvalid = "Email address is invalid"
        
        static let PasswordEmpty = "Password is empty"
        static let PasswordInvalid = "Password is invalid"
        
        static let NoFriendFound = "No friends found"
        static let NoUserFound = "No users found"
        
        static let MessageEmpty = "Message is empty"
        static let NoChatAvailable = "No chats available"
    }
    
    struct DateTimeFormatter {
        
        static let date1 = "dd MMM YYYY"
        static let date2 = "hh:mm a"
    }
}
